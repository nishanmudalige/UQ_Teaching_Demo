"""ChatKit server for the equal-variance ANOVA teaching panel."""
from __future__ import annotations

import os
from typing import Any, AsyncIterator

from agents import Agent, Runner
from chatkit.agents import AgentContext, simple_to_agent_input, stream_agent_response
from chatkit.server import ChatKitServer
from chatkit.types import ThreadMetadata, ThreadStreamEvent, UserMessageItem

from .memory_store import MemoryStore

MAX_RECENT_ITEMS = 30
MODEL = os.getenv("OPENAI_MODEL", "gpt-4.1-mini")

assistant_agent = Agent[AgentContext[dict[str, Any]]](
    model=MODEL,
    name="ANOVA teaching assistant",
    instructions=(
        "You are a concise statistics teaching assistant embedded in a university "
        "slide about the equal-variance assumption for one-way ANOVA. "
        "Help students reason from side-by-side boxplots and group standard "
        "deviations. Explain what equal variance means, how to compare spread, "
        "and why exact equality is not required. Distinguish visual/descriptive "
        "checks from formal procedures when relevant. Do not invent numerical "
        "values that the student has not supplied. If the student provides the "
        "group SDs or R output, interpret those values directly. Keep answers "
        "short, clear, and suitable for a second-year statistics course."
    ),
)


class AnovaChatServer(ChatKitServer[dict[str, Any]]):
    def __init__(self) -> None:
        self.store: MemoryStore = MemoryStore()
        super().__init__(self.store)

    async def respond(
        self,
        thread: ThreadMetadata,
        item: UserMessageItem | None,
        context: dict[str, Any],
    ) -> AsyncIterator[ThreadStreamEvent]:
        items_page = await self.store.load_thread_items(
            thread.id,
            after=None,
            limit=MAX_RECENT_ITEMS,
            order="desc",
            context=context,
        )
        items = list(reversed(items_page.data))
        agent_input = await simple_to_agent_input(items)
        agent_context = AgentContext(
            thread=thread,
            store=self.store,
            request_context=context,
        )
        result = Runner.run_streamed(
            assistant_agent,
            agent_input,
            context=agent_context,
        )
        async for event in stream_agent_response(agent_context, result):
            yield event
