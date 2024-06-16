import functools
import os
from utils import build_graph, show_graph
from agents import create_agent, AgentStateCustom
from nodes import planner_node, task_generator_node, task_critic_node, task_critic_router, task_critic_critic_node, task_critic_critic_router
from langchain_nvidia_ai_endpoints import ChatNVIDIA


os.environ["NVIDIA_API_KEY"] = "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"


llm = ChatNVIDIA(model="meta/llama3-70b-instruct")


# load prompt from file
with open("prompts/narrator.txt", "r") as f:
    prompt = f.read()

planner_agent = create_agent(llm, prompt)
planner_node_ = functools.partial(planner_node, agent=planner_agent)

with open("prompts/prompt_task_generator.txt", "r") as f:
    prompt = f.read()

task_generator_agent = create_agent(llm, prompt)
task_generator_node_ = functools.partial(task_generator_node, agent=task_generator_agent)

with open("prompts/prompt_task_critic_2.txt", "r") as f:
    prompt = f.read()

task_critic_agent = create_agent(llm, prompt)
task_critic_node_ = functools.partial(task_critic_node, agent=task_critic_agent)

with open("prompts/prompt_task_critic_critic.txt", "r") as f:
    prompt = f.read()

task_critic_critic_agent = create_agent(llm, prompt)
task_critic_critic_node_ = functools.partial(task_critic_critic_node, agent=task_critic_critic_agent)


nodes = [("Planner", planner_node_), ("Task Generator", task_generator_node_), ("Task Critic", task_critic_node_), ("Task Critic Critic", task_critic_critic_node_)]
edges = [("Planner", lambda s: "continue", {"continue": "Task Generator"}),
         ("Task Generator", lambda s: "continue", {"continue": "Task Critic"}),
         ("Task Critic", task_critic_router, {"Planner": "Planner", "Task Critic Critic": "Task Critic Critic"}),
         ("Task Critic Critic", task_critic_critic_router, {"Planner": "Planner", "Task Generator": "Task Generator"})]
# nodes = [("Planner", planner_node_), ("Task Generator", task_generator_node_)]
# edges = [("Planner", lambda s: "continue", {"continue": "Task Generator"}),
#          ("Task Generator", lambda s: "continue", {"continue": "Planner"})]

state_class = AgentStateCustom
entry_point = "Planner"
graph = build_graph(state_class, nodes, edges, entry_point)


def start(prompt):
    events = graph.stream(
        {
            "plan": prompt
        },
        # Maximum number of steps to take in the graph
        {"recursion_limit": 150},
    )
    for s in events:
        print(s)
        print("----")
        #time.sleep(60)


if __name__ == "__main__":
    start("draw a computer")
    #show_graph(graph)

