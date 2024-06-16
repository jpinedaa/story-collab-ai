import operator
from langchain_core.messages import AIMessage, BaseMessage
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langgraph.graph import StateGraph
from PIL import Image
import io



def show_graph(graph):
    # show image
    graph_image = graph.get_graph(xray=True).draw_mermaid_png()

    # Convert bytes to a file-like object
    graph_image_file = io.BytesIO(graph_image)

    # Open the image file
    img = Image.open(graph_image_file)

    ## Display the image
    img.show()


def parse_output(output):
    stack = []
    result = ""
    start_index = None

    for i, char in enumerate(output):
        if char == '[':
            if not stack:
                start_index = i
            stack.append(char)
        elif char == ']':
            if stack:
                stack.pop()
                if not stack:
                    result = output[start_index:i + 1]
            else:
                raise ValueError("Unmatched closing bracket found")

    if stack:
        raise ValueError("Unmatched opening bracket found")

    if result:
        return result
    else:
        raise ValueError(
            "No brackets found or multiple non-overlapping sets of brackets")


def parse_output_planner(output_str):
    """
    Parse the output string from the LLM into a dictionary.

    Parameters:
    output_str (str): The output string from the LLM.

    Returns:
    dict: A dictionary containing the updated plan and current task.
    """

    def find_section(output_str, start_marker, end_marker):
        start_idx = output_str.find(start_marker)
        if start_idx == -1:
            return None, -1
        start_idx += len(start_marker)

        # Initialize bracket count to handle nested brackets
        bracket_count = 1
        for i in range(start_idx, len(output_str)):
            if output_str[i] == '[':
                bracket_count += 1
            elif output_str[i] == ']':
                bracket_count -= 1
                if bracket_count == 0:
                    end_idx = i
                    return output_str[start_idx:end_idx].strip(), end_idx + 1
        return None, -1

    # Find the sections
    updated_plan_marker = "[updated_plan:"
    current_task_marker = "[current_task:"
    end_marker = "]"

    plan, plan_end = find_section(output_str, updated_plan_marker, end_marker)
    task, _ = find_section(output_str[plan_end:], current_task_marker,
                           end_marker)

    return plan, task


def parse_output_task_generator(output_str):
    """
       Parse the output string from the LLM into a list of OpenCV commands.

       Parameters:
       output_str (str): The output string from the LLM.

       Returns:
       list: A list of OpenCV commands.
       """
    # Removing unnecessary whitespace and newlines
    output_str = output_str.strip()

    # Finding the start and end of the commands list
    commands_start = output_str.find("[")
    commands_end = output_str.rfind("]") + 1

    # Extracting the commands list
    commands_str = output_str[commands_start:commands_end]

    # Converting the string to a list of commands
    commands_list = eval(commands_str)

    return commands_list


def parse_output_task_critic(output_str):
    """
       Parse the refined current task from the LLM output.

       Parameters:
       output_str (str): The output string from the LLM.

       Returns:
       str: The refined current task.
       """
    # Define the markers
    reasoning_marker = "REASONING:"
    refined_task_marker = "REFINED_CURRENT_TASK:"

    # Find the starting position of each marker
    reasoning_start = output_str.find(reasoning_marker)
    refined_task_start = output_str.find(refined_task_marker) + len(
        refined_task_marker)

    # Find the ending position of the refined current task
    refined_task_end = output_str.find("]", refined_task_start)

    # Extract the refined current task
    refined_current_task = output_str[
                           refined_task_start:refined_task_end].strip()

    return refined_current_task


def parse_output_task_critic_2(output_str):
    """
       Parse the refined current task and commands feedback from the LLM output.

       Parameters:
       output_str (str): The output string from the LLM.

       Returns:
       tuple: The refined current task and commands feedback.
       """
    # Define the markers
    refined_task_marker = "REFINED_CURRENT_TASK:"
    commands_feedback_marker = "COMMANDS_FEEDBACK:"

    # Find the starting position of each marker
    refined_task_start = output_str.find(refined_task_marker) + len(refined_task_marker)
    commands_feedback_start = output_str.find(commands_feedback_marker) + len(commands_feedback_marker)

    # Find the ending position of the refined current task
    refined_task_end = output_str.find("]", refined_task_start)

    # Find the ending position of the commands feedback
    commands_feedback_end = output_str.find("]", commands_feedback_start)

    # Extract the refined current task
    refined_current_task = output_str[refined_task_start:refined_task_end].strip()

    # Extract the commands feedback
    commands_feedback = output_str[commands_feedback_start:commands_feedback_end].strip()

    return refined_current_task, commands_feedback



def build_graph(state_class, nodes, edges, entry_point):
    workflow = StateGraph(state_class)

    for node in nodes:
        workflow.add_node(node[0], node[1])

    for edge in edges:
        workflow.add_conditional_edges(edge[0], edge[1], edge[2])

    workflow.set_entry_point(entry_point)
    graph = workflow.compile()
    # show_graph(graph)

    return graph