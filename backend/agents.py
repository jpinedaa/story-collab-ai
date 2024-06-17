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


class SceneState(TypedDict):
    messages: Annotated[Sequence[BaseMessage], operator.add]
    title: str
    description: str
    place: str
    challenges: list[str]
    pickup_cards: list[str]


class MoveState(TypedDict):
    messages: Annotated[Sequence[BaseMessage], operator.add]
    description: str
    challenges: list[str]
    played: list[str]
    pickup_cards: list[str]

class SelectionState(TypedDict):
    messages: Annotated[Sequence[BaseMessage], operator.add]
    character: str