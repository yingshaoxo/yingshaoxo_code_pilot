import vim
import re
import time
import multiprocessing

from auto_everything.terminal import Terminal
terminal = Terminal()

from auto_everything.io import IO
io_ = IO()

from auto_everything.disk import Disk
disk = Disk()

from auto_everything.ml import Yingshaoxo_Text_Generator

current_working_directory = terminal.run_command("pwd")
current_file_type = vim.eval("expand('%:e')")
seperator = "\n\n\n"

type_list = ["."+current_file_type, ".md", ".py", ".txt", ".js", ".ts", ".c", ".cpp", ".cc", ".rs", ".go", ".java", ".kt", ".sh", ".dart", ".css", ".less"]
#type_list = ["."+current_file_type, ".py", ".js", ".ts", ".sh", ".css", ".less"]

data_source_text = ""
def get_data_source_text(message_queue):
    files = disk.get_files(folder=current_working_directory, recursive=True, type_limiter=type_list, use_gitignore_file=True)
    data_source_text = ""
    for file in files:
        data_source_text += io_.read(file) + "\n\n\n\n"
    message_queue.put(data_source_text)

# set data_source_text to "" when source folder is too big for reading. timeout is 3 seconds
message_queue = multiprocessing.Queue()
a_process = multiprocessing.Process(target=get_data_source_text, args=(message_queue, ))
a_process.start()
start_time = time.time()
while True:
    if not message_queue.empty():
        data_source_text = message_queue.get()
        break

    current_time = time.time()
    if (current_time - start_time) > 3:
        data_source_text = ""
        break
    time.sleep(0.2)
if a_process.is_alive():
    a_process.kill()


yingshaoxo_tokenizer = None
yingshaoxo_model = None
yingshaoxo_device = None


def complete_the_rest():
    print("I'm in working, please wait...")

    lines = vim.current.buffer[:]

    current_line_index = int(vim.eval('line(".")')) - 1
    current_line = lines[current_line_index]
    #print(current_line_index)

    previous_text = "\n".join(lines[: current_line_index+1])
    previous_text = previous_text.split(seperator)[-1].strip()
    #print(previous_text)

    found = Yingshaoxo_Text_Generator.next_code_generation(data_source_text=data_source_text, input_text=previous_text, type_limiter=type_list, how_long_the_text_you_want_to_get=512)

    found = found.split(seperator)[0]
    #print(found)
    splits = found.split("\n")
    vim.current.line += splits[0]
    for index, line in enumerate(splits[1:]):
        vim.current.buffer.append(line, current_line_index+index+1)

    print("Done.")


def complete_with_codet5():
    global yingshaoxo_model, yingshaoxo_tokenizer, yingshaoxo_device
    try:
        print("I'm in working, please wait...")

        if (yingshaoxo_model == None or yingshaoxo_tokenizer == None or yingshaoxo_device == None):
            import os
            os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'
            import tensorflow as tf
            tf.get_logger().setLevel('ERROR')

            from transformers import T5ForConditionalGeneration, AutoTokenizer, logging
            logging.set_verbosity(logging.ERROR)

            checkpoint = "Salesforce/codet5p-220m-py"
            yingshaoxo_device = "cuda"

            yingshaoxo_tokenizer = AutoTokenizer.from_pretrained(checkpoint)
            yingshaoxo_model = T5ForConditionalGeneration.from_pretrained(checkpoint).to(yingshaoxo_device)

        lines = vim.current.buffer[:]

        current_line_index = int(vim.eval('line(".")')) - 1
        current_line = lines[current_line_index]
        #print(current_line_index)

        previous_text = "\n".join(lines[: current_line_index+1])
        previous_text = previous_text.split("\n\n")[-1].strip()
        #print(previous_text)

        inputs = yingshaoxo_tokenizer.encode(previous_text, return_tensors="pt").to(yingshaoxo_device)
        outputs = yingshaoxo_model.generate(inputs, max_length=512)
        found = yingshaoxo_tokenizer.decode(outputs[0], skip_special_tokens=True)

        #found = found.split(seperator)[0]
        #print(found)
        splits = found.split("\n")
        vim.current.line += splits[0]
        for index, line in enumerate(splits[1:]):
            vim.current.buffer.append(line, current_line_index+index+1)

        print("Done.")
    except Exception as e:
        print(e)
