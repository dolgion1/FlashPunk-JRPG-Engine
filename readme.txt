This is the complete source code for my JRPG Engine powered by the FlashPunk library.
Its aim is to enable a developer to make a game with traditional JRPG elements:

- Having an avatar walking around a tilemap
- Having dialog with NPCs 
- Move from one map to a different map
- Turn-based and real-time combat
- Item management, equipment
- Skills and Magic
- Quests and Journaling
- World Map 
- Script sequences/ Cutscenes
- more stuff as development continues...

I've also decided to accompany this effort with a tutorial series over on 
my blog (http://thedoglion.wordpress.com). As the way the first 4 tutorials were
made became proportionally as impractical as the code grew in size with every single
added feature, I decided to open-source my main branch (meaning NOT the code that 
was developed in the first 4 tutorials), and continue my tutorials with reference to
defined commits/snapshots of the latest branch up here on GitHub.

This current release has the following features implemented, even if not in a perfect way:

- Avatar movement
- Multiple Map navigation for the player
- Indoors and outdoors maps
- NPCs with pathfinding. They can navigate their way around the multiple maps
- Daytime counter and display thereof
- Current location display
- A primitive world map
- Dataloading from xml files, to lessen hard coding and make code more modular