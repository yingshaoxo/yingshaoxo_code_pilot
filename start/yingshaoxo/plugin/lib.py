import re
import time
import multiprocessing
import sys
import argparse

#print(f"Using Python {sys.version.split()[0]}", file=sys.stderr)

from auto_everything.terminal import Terminal
terminal = Terminal()

from auto_everything.io import IO
io_ = IO()

from auto_everything.disk import Disk
disk = Disk()

from auto_everything.ml import Yingshaoxo_Text_Generator

def get_data_source_text(message_queue, current_working_directory, type_list):
    files = disk.get_files(folder=current_working_directory, recursive=True, type_limiter=type_list, use_gitignore_file=True)
    data_source_text = ""
    for file in files:
        data_source_text += io_.read(file) + "\n\n\n\n"
    message_queue.put(data_source_text)

def complete_the_rest(current_working_directory, input_text, max_length):
    # Get file extension from the current input
    current_file_type = ""
    if "." in input_text:
        possible_extension = input_text.split(".")[-1].split()[0]
        if len(possible_extension) <= 4:  # Most file extensions are 4 chars or less
            current_file_type = possible_extension

    type_list = ["."+current_file_type, ".md", ".py", ".txt", ".js", ".ts", ".c", ".cpp", ".cc", ".rs", ".go", ".java", ".kt", ".sh", ".dart", ".css", ".less"] if current_file_type else [".py", ".js", ".ts", ".sh", ".css", ".less"]
    seperator = "\n\n\n"

    # Initialize data source text with timeout
    data_source_text = ""
    message_queue = multiprocessing.Queue()
    a_process = multiprocessing.Process(target=get_data_source_text, args=(message_queue, current_working_directory, type_list))
    a_process.start()
    
    start_time = time.time()
    while True:
        if not message_queue.empty():
            data_source_text = message_queue.get()
            break

        current_time = time.time()
        if (current_time - start_time) > 0.5:  # 0.5 second timeout
            files = disk.get_files(folder=current_working_directory, recursive=False, type_limiter=type_list, use_gitignore_file=True)
            for file in files:
                data_source_text += io_.read(file) + "\n\n\n\n"
            break
        time.sleep(0.05)
    
    if a_process.is_alive():
        a_process.kill()

    # Generate completion
    found = Yingshaoxo_Text_Generator.next_code_generation(
        data_source_text=data_source_text,
        input_text=input_text,
        type_limiter=type_list,
        how_long_the_text_you_want_to_get=max_length
    )
    #found = Yingshaoxo_Text_Generator().next_fuzz_sentence_generation(
    #    text_source_data=data_source_text, 
    #    input_text=input_text, 
    #    how_long_the_text_you_want_to_get=max_length
    #)

    found = found.split(seperator)[0]
    return found

def find_string(folder_path, search_string, start_from=0):
    start_from = int(start_from)
    files = disk.get_files(folder=folder_path, recursive=True, use_gitignore_file=True)
    counting = 0
    results = []
    
    def tokenize(text):
        # Split on punctuation and whitespace, remove empty strings
        # For Chinese text, just return the full string as one token
        if any('\u4e00' <= char <= '\u9fff' for char in text):
            return [text.strip()]
        return [t for t in re.split(r'[\s\W]+', text) if t]
    
    search_tokens = tokenize(search_string)
    if not search_tokens:
        return []
        
    for file in files:
        try:
            with open(file, "r", encoding='utf-8') as f:
                text = f.read()
            lines = text.split("\n")
            for index, line in enumerate(lines):
                if line.strip() and line.strip()[0] not in ["#", '"', "'", "/"]:
                    # For Chinese text, do direct string containment check
                    if any('\u4e00' <= char <= '\u9fff' for char in search_string):
                        if search_string in line:
                            next_text = "\n".join(lines[index:index + 20])
                            results.append({
                                'text': next_text,
                                'file': file,
                                'line': index + 1
                            })
                    else:
                        # For non-Chinese text, use token matching
                        line_tokens = tokenize(line)
                        if all(token in line for token in search_tokens):
                            next_text = "\n".join(lines[index:index + 20])
                            results.append({
                                'text': next_text,
                                'file': file,
                                'line': index + 1
                            })
        except Exception as e:
            # Try with different encodings if UTF-8 fails
            try:
                with open(file, "r", encoding='gbk') as f:
                    text = f.read()
                lines = text.split("\n")
                for index, line in enumerate(lines):
                    if line.strip() and line.strip()[0] not in ["#", '"', "'", "/"]:
                        if search_string in line:
                            next_text = "\n".join(lines[index:index + 20])
                            results.append({
                                'text': next_text,
                                'file': file,
                                'line': index + 1
                            })
            except Exception as e:
                pass
    
    if start_from < len(results):
        return results[start_from:]
    return []

def main():
    parser = argparse.ArgumentParser(description='Code completion and search tool')
    parser.add_argument('current_code_folder', help='The folder containing the code')
    parser.add_argument('input_code', help='The input code (previous lines + current line)')
    parser.add_argument('max_length', type=int, help='How long the following text you want to get')
    parser.add_argument('--mode', choices=['complete', 'search'], default='complete', help='Operation mode')
    parser.add_argument('--start-from', type=int, default=0, help='Start index for search results')
    
    args = parser.parse_args()
    
    try:
        if args.mode == 'search':
            results = find_string(args.current_code_folder, args.input_code, args.start_from)
            # Output results in JSON format for easy parsing in Vim
            import json
            print(json.dumps(results))
        else:
            result = complete_the_rest(args.current_code_folder, args.input_code, args.max_length)
            print(result)
    except Exception as e:
        print(f"Error: {str(e)}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()

