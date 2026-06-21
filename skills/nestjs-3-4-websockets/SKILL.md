---
name: nestjs-3-4-websockets
description: Review NestJS WebSocket gateway and communication implementation, covering @WebSocketGateway, event handling, room management, and authentication strategies. Use when users need to review or develop real-time communication functionality.
---

# NestJS Network Communication and WebSockets

## Overview

When AI encounters WebSocket related code in a NestJS project, it automatically performs the following: review the WebSocket gateway configuration and event handling, check room management and broadcast mechanisms, evaluate connection authentication and exception handling strategies, and provide improvement suggestions.

## Definitions

- <a id="target-code"></a>**Target code**: The NestJS WebSocket gateway implementation code or client communication code in the current conversation.
- <a id="gateway"></a>**Gateway**: A class decorated with @WebSocketGateway that handles WebSocket connections, event sending/receiving, and room management.
- <a id="websocket-exception-filter"></a>**WebSocket exception filter**: A filter implementing the WsExceptionFilter interface, specifically designed for handling exceptions in WebSocket scenarios.
- <a id="analysis-complete"></a>**Analysis complete**: Indicates whether the analysis of the target code has been fully completed.

## Prerequisites

- NestJS project environment (including @nestjs/websockets and @nestjs/platform-socket.io dependencies);
- WebSocket gateway code files accessible;
- Understanding of WebSocket protocol and Socket.io basic usage.

## Workflow

0. **Pre-check** — Ensure the target code and runtime environment are reachable;
   - Determine if the target code exists and is readable:
     - Yes -> next step;
     - No -> prompt the user to provide the target code or file path, block and wait for user input;
   - Initialize global variable [analysis complete](#analysis-complete):
     - Determine if the code is fully parseable:
       - Satisfied -> initialize variable to true;
       - Not satisfied -> initialize variable to false;

1. **Analyze WebSocket code** — Read and understand gateways and event handling;
   - Read the target code, identify the following core elements:
     - @WebSocketGateway decorator configuration (namespace, port, cors);
     - @SubscribeMessage decorated event handler methods;
     - Server instance injected using @WebSocketServer;
     - Room management operations (joinRoom / leaveRoom);
     - Other services injected in the gateway;

2. **Review items** — Check WebSocket code quality against the review checklist;
   - Iterate through the following review items to determine if they pass:
     - Whether CORS is configured (cors option in @WebSocketGateway to prevent cross-origin issues):
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "WebSocket gateway has no cors configured, may cause cross-origin issues on the browser side", continue;
     - Whether connection and disconnection lifecycle hooks handle necessary cleanup (handleConnection / handleDisconnect):
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "handleDisconnect lacks resource cleanup logic, may cause connection leaks", continue;
     - Whether WebSocket authentication is implemented (verify token in handleConnection):
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "Gateway has no connection authentication, unauthorized clients can establish connections", continue;
     - Whether errors in event handlers are caught (using WsException or try/catch):
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "Event handlers do not catch exceptions, may cause client connection disconnection", continue;
     - Whether room management is used for message broadcasting (avoid sending messages to all clients):
       - Pass -> record as passed, continue to next review item;
       - Fail -> record "Recommend using server.to(room).emit() for broadcasting to specific rooms instead of global broadcast", continue;
   - Determine if there are any issue records:
     - Yes -> compile issue list, proceed to next step;
     - No -> directly proceed to step 4 (review check);

3. **Provide modification suggestions** — Give specific fixes for identified issues;
   - Provide fix suggestions for each issue in sequence;
   - Offer options via AskUserQuestion, block and wait for user selection:
     - Accept all suggestions -> generate corrected code, proceed to step 4;
     - Confirm one by one -> let the user decide to accept or ignore each item, proceed to step 4 after all confirmed;
     - Review only without modification -> do not affect code, directly proceed to step 4;

4. **Review check** — Confirm execution results against [Review List](#review-list);
   - Determine if Review List has content:
     - No -> directly proceed to next step (output);
     - Yes -> next step;
   - Check each item in [Review List](#review-list) sequentially to see if it passes:
     - Display output based on the "Review check example";
   - If any check fails, terminate the process;
   - After all pass, proceed to next step;

5. **Output results** — Output review summary, inform completion;
   - Output structured summary table (reviewed file / number of review items / passed / issues found / risk level / adopted suggestions);
   - Inform the review is complete;

## Rules

- **Content rules**
  - description must follow format: first sentence describes review content, second sentence describes trigger condition, use third person, no more than 1024 characters;
  - Review items must reference NestJS official WebSocket documentation;
  - SKILL.md no more than 300 lines; split to references/ directory when exceeded;
  - Reference hierarchy no more than one level;
  - Maintain terminology consistency, terms defined in Definitions must be referenced via anchor links in the body;
  - Remove any time-sensitive information;

- **Behavior rules**
  - Only output issue summaries and locations during review, do not directly modify code unless the user explicitly requests via AskUserQuestion;
  - All interaction steps involving code modification must use the AskUserQuestion tool;
  - Specific authentication strategy implementation (JWT / Session) should be labeled as architectural choice, not a defect;

- **Defensive rules**
  - If target code is empty or unreadable, report directly and terminate;
  - Room broadcast optimization suggestions should only be provided when explicit global broadcast exists, do not force room usage;

- **Validation rules**
  - Examples content must be self-consistent with Rules;
  - Examples must include a review check example;
  - Dialogue interaction examples should only focus on steps 0~3 (excluding review check and output);

## Examples

### Dialogue Interaction Example

**Example: User requests WebSocket gateway review**

```markdown
User > Help me check this chat gateway implementation
AI   > Detected user needs NestJS WebSocket review, triggered nestjs-3-4-websockets skill
AI   > Analyzing gateway code...

Review Results:
- 🟥 @WebSocketGateway has no cors option configured
- 🟩 handleDisconnect cleans up user rooms
- 🟥 No authentication in handleConnection
- 🟩 Event errors handled with WsException
- 🟥 Using server.emit for global broadcast (should use room)

Summary: 3 issues need attention
User > Help me add authentication and room broadcast
AI   > Need to verify token in handleConnection and switch to to(room).emit. Apply?
User > Accept all
```

### Review Check Example

```markdown
AI > Entering review check, Review List contains 5 items, starting verification:

**Content Check**
  - 🟩 All review items reference official documentation
  - 🟩 Authentication strategy labeled as architectural choice

**Behavior Check**
  - 🟩 Did not directly modify user code
  - 🟩 Used AskUserQuestion

**Validation Check**
  - 🟩 Room suggestions provided when global broadcast exists
  - 🟩 Output summary is complete

✅ All passed, proceeding to output.
```

### Output Example

**Review Result Example:**

```markdown
| Dimension | Result |
| --- | --- |
| Reviewed File | src/chat/chat.gateway.ts |
| Total Review Items | 6 items |
| Passed | 3 items |
| Issues Found | 3 items |
| Risk Level | 🟡 Medium |
| Suggestions Adopted | 3 items |
```

## Review List

- **Content Check**
  - [ ] All review items reference NestJS official WebSocket documentation
  - [ ] Authentication strategy labeled as architectural choice
- **Behavior Check**
  - [ ] Did not directly modify user code (unless explicitly requested by the user)
  - [ ] All interaction steps used AskUserQuestion
- **Validation Check**
  - [ ] Correctly terminated when target code is empty or unreadable
  - [ ] Room broadcast suggestion provided when global broadcast exists
  - [ ] Output summary includes file path, number of review items, issues found, and risk level

## References

- [NestJS WebSocket Official Documentation](https://docs.nestjs.com/websockets/gateways)
- [Socket.io Documentation](https://socket.io/docs/v4/)
- [skill-evolve Template](../../skill-evolve/template.md)
