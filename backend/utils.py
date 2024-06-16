import json
import re
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


def parse_scene_generation(output):
    # Regular expression pattern to match JSON object
    json_pattern = re.compile(r'\{(?:[^{}]|(?:\{[^{}]*\}))*\}')

    # Find all JSON objects in the output
    json_matches = json_pattern.findall(output)

    if not json_matches:
        raise ValueError("No JSON object found in the LLM output.")

    for match in json_matches:
        try:
            # Attempt to load the JSON object
            parsed_output = json.loads(match)

            # Verify the structure of the parsed output
            if all(key in parsed_output for key in
                   ["place", "challenges", "pickups", "title", "description"]):
                return parsed_output['title'], parsed_output['description'], \
                parsed_output['place'], parsed_output[
                    'challenges'], parsed_output['pickups']
        except json.JSONDecodeError:
            continue

    raise ValueError(
        "No valid JSON object with the required structure found in the LLM output.")


def parse_move_generation(output):
    # Regular expression pattern to match JSON object
    json_pattern = re.compile(r'\{(?:[^{}]|(?:\{[^{}]*\}))*\}')

    # Find all JSON objects in the output
    json_matches = json_pattern.findall(output)

    if not json_matches:
        raise ValueError("No JSON object found in the LLM output.")

    for match in json_matches:
        try:
            # Attempt to load the JSON object
            parsed_output = json.loads(match)

            # Verify the structure of the parsed output
            if all(key in parsed_output for key in
                   ["challenges", "played", "description", "pickups"]):
                return parsed_output['played'], parsed_output['description'], \
                parsed_output['challenges'], parsed_output['pickups']
        except json.JSONDecodeError:
            continue

    raise ValueError(
        "No valid JSON object with the required structure found in the LLM output.")


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