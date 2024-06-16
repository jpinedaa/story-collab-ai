import operator
from datetime import datetime
from langchain_core.messages import BaseMessage
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from typing_extensions import TypedDict, Annotated, Sequence


def create_agent(llm, system_message: str):
    """Create an agent."""
    prompt = ChatPromptTemplate.from_messages(
        [
            (
                "system",
                "{system_message}"
            ),
            MessagesPlaceholder(variable_name="messages"),
        ]
    )
    prompt = prompt.partial(system_message=system_message)

    return prompt | llm


class AgentState(TypedDict):
    messages: Annotated[Sequence[BaseMessage], operator.add]
    sender: str
    # time.now type
    last_time: datetime


class AgentStateCustom(TypedDict):
    plan: str
    current_task: str
    current_image: str
    previous_image: str
    commands: str
    commands_feedback: str
    approved: bool
    generator_messages: Annotated[Sequence[BaseMessage], operator.add]


class TreeNode:
    def __init__(self, image, commands, parent=None):
        self.image = image
        self.commands = commands
        self.parent = parent
        self.children = []

    def add_child(self, child):
        self.children.append(child)
        child.parent = self


class TreeOfThoughts:
    def __init__(self, root):
        self.root = root
        self.current_node = root

    def add_node(self, node):
        self.current_node.add_child(node)
        self.current_node = node

    def back(self):
        self.current_node = self.current_node.parent


class AgentStateToT(TypedDict):
    messages: Annotated[Sequence[BaseMessage], operator.add]
    sender: str
    last_time: datetime
    tree: TreeOfThoughts
    current_node: TreeNode
    root: TreeNode
