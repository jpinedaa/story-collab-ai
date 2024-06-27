## Narravive
Narravive is an app that breathes life into stories through collaborative writing. Using story cards, you can craft rich narratives as various agents take control of different characters. Whether you let the agents operate independently or choose to guide characters yourself, you can seamlessly collaborate with both humans and AI agents. Narravive transforms storytelling into a distributed and asynchronous experience, allowing complex narratives to emerge organically from the interplay of multiple contributors.

https://github.com/jpinedaa/story-collab-ai/assets/22211084/b89e6286-f276-442c-9a3c-599b7f213572

### Getting Started

1. Download the latest release: https://github.com/jpinedaa/story-collab-ai/releases/tag/v.0.0.2
2. Unzip the file
3. Run Narravive.exe

#### Setting the model
1. Click the settings Icon on the top right corner
2. Set your api key and model from [NVIDIA NIMS](https://build.nvidia.com/explore/discover)
3. Click save

#### Selecting a Character
1. Select the narrator or a character by clicking the respective card at the top
2. The selected card will turn blue
3. Hover your mouse over a character to see the full card for that character

#### Creating Story Cards

1. Select the narrator or the character you want to create a card for
2. Click the plus icon on the top right corner
3. Click on create new card
4. Write a title and description and set a card type
5. Optional: click pick an image to select an image for the card
6. Click Save

#### Creating a character
1. Select the narrator and create a new card
2. In the card creation form select Character as the card type
3. Set the player status
    * Auto: Character is controlled by an agent
    * Manual: Character is controlled by the user
    * NPC: Character is not controllable and can be used as an obstacle by the narrator

#### Editing a card
1. Select the narrator or the character you want to create a card for
2. Click the plus icon on the top right corner
3. Select the card you want to edit
4. Click the blue pencil Icon at the top left corner
5. Edit the desired text.
6. Click Save

#### Deleting a card
1. Select the narrator or the character you want to create a card for
2. Click the plus icon on the top right corner
3. Select the card you want to delete
4. Click the red trashcan Icon at the top left corner

#### Duplicating a card
1. Select the narrator or the character you want to create a card for
2. Click the plus icon on the top right corner
3. Select the card you want to duplicate
4. Click the green plus 1 Icon at the top left corner

#### Saving a story state
1. Click the purple save button at the top right corner
2. Select a directory and filename and click save.

#### Opening a story state
1. Click the yellow folder icon at the top right corner
2. Select the story state file (.json) and click open

#### Resetting a story state
1. Save the current state or it will be deleted
2. Click the red reset button at the top right corner

### Story Creation Flow
#### Story Cards
Story cards represent different aspects of your story such as people, places, and situations. 
You and the characters use these cards to set up interesting situations, describe the action, and move the story forward. 
Think of story cards as writing prompts that inspire ideas and suggestions as you write.

#### Narrator Cards
Narrators have three kinds of cards, which they use to establish each scene of the story and put forth challenges for the other players to overcome:
* Place: The locations where each scene unfolds in your story.
* Character: People in the story who challenge the players or want something from them.
* Obstacle: Anything else in the story that challenges or hinders the players.

#### Character Cards
Characters have six kinds of cards, which describe their actions in the story and help them overcome the narrator’s challenges:

* Nature: A character’s background or origin.
* Strength: A character’s traits or abilities that give them an edge.
* Weakness: A character’s limitations or shortcomings that trip them up.
* Subplot: A character’s central motivation — the thing that drives them.
* Asset: Something unique or important that can be used to affect the story.
* Goal: A task that a player can choose to take on for a reward.
  
#### How the Story Writing Works
##### Scenes
Stories unfold as a series of scenes. When starting a new scene, the narrator creates challenges by using their cards. Challenges come in two forms:
* Character Cards: Represent people who confront the characters or want something from them.
* Obstacle Cards: Represent anything else that gets in the characters’ way.

Every challenge has an initial counter of three (3) moves that characters need to play to overcome the challenge. 

Once the narrator has played their cards, they write a brief description of the situation, setting the stage.

The narrator can also leave pickup cards in the scene that the character can take and play to overcome challenges.

##### Moves

After the scene has started, the characters make one or more moves by playing their cards to show how they overcome the narrator's challenges. These cards include:

Strength and Weakness Cards: Represent the abilities or shortcomings that set your character apart.

* Subplot: Describes a character's motivation.
* Assets: Valuable things or knowledge that give characters an edge.
* Goals: Tasks or objectives that players can choose to take on for a reward.

Once a card has been played it can't be used anymore, you can create new cards at any point or pickup cards from the scene left by the narrator.

##### Winning Control of the Story
Playing these cards helps overcome the narrator’s challenges and earns you the chance to win control of the story. This means you can write how the challenge turns out, using “outcomes” guided by the challenge card.

##### Advancing the Story
Once all the scene’s challenges have been overcome, the scene is complete. The narrator can then start the next one by adding new challenges.

### Auto Mode
Auto Mode is the main engine of Narravive, allowing agents to play as characters or narrators, following the rules with their own contexts. Here’s how it works:

* Order: Determined by the narrator.
* Turns: When a character or narrator runs out of cards to play, the turn stops. Auto mode stops when a manual character or narrator turn occurs.
* Dynamic Control: Set some characters to auto or manual to control specific parts of the story. You can create story cards at any point, providing flexibility in storytelling.
* Agent Interaction: Multiple agents follow the established rules, interacting with their unique contexts to drive the story forward.

### Notes
* Create Cards First: Before you can start playing, you need to create your story and character cards.
* Edit Rules: You can only edit the last scene or move.
* You can save or open stories, and your last workflow is automatically saved

### Technology Integration
Narravive integrates NVIDIA technologies for a seamless storytelling experience:
* Langchain Nvidia Chat: For interactive conversations.
* NIMS Endpoints: For robust backend support.
* Model Selection: Choose the best models for your needs.
* API Key Encryption: Ensures security for your keys.
* Langgraph: Facilitates modularizable agents.

### Conclusion
Narravive offers a unique platform for dynamic, collaborative storytelling. Whether you're controlling characters or letting AI agents drive the narrative, the stories created are truly living and organic.
