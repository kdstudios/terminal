import 'story_model.dart';
import 'stories/below.dart';
import 'stories/caravan.dart';
import 'stories/transmission.dart';

/// Every Story Expedition, in the order they are listed on the selection screen.
/// To add a story: write a [StoryDef] in stories/ and add it here.
final List<StoryDef> storyCatalog = [
  transmissionStory,
  caravanStory,
  belowStory,
];

StoryDef? storyDefOrNull(String id) {
  for (final s in storyCatalog) {
    if (s.id == id) return s;
  }
  return null;
}

// ---- checkpoint scenes ride on the existing choice-encounter screen. Their
// session id is  story:<storyId>:<checkpointId>.

bool isStorySession(String id) => id.startsWith('story:');

String storySessionId(String storyId, String cpId) => 'story:$storyId:$cpId';

class StoryRef {
  final String story, cp;
  const StoryRef(this.story, this.cp);
}

StoryRef? parseStorySession(String id) {
  if (!isStorySession(id)) return null;
  final p = id.split(':');
  if (p.length != 3) return null;
  return StoryRef(p[1], p[2]);
}

Checkpoint? checkpointOf(StoryDef d, String? cpId) {
  if (cpId == null) return null;
  for (final c in d.checkpoints) {
    if (c.id == cpId) return c;
  }
  return null;
}

/// True when a saved story scene can still be shown (the story, checkpoint and
/// scene exist and the run is known). Otherwise a load drops it safely.
bool storySessionValid(String id, String scene, StoryBook book) {
  final ref = parseStorySession(id);
  if (ref == null) return false;
  final d = storyDefOrNull(ref.story);
  if (d == null || !book.runs.containsKey(ref.story)) return false;
  final cp = checkpointOf(d, ref.cp);
  return cp != null && cp.sceneMap.containsKey(scene);
}

String storyEventTitle(String id) {
  final ref = parseStorySession(id);
  final d = ref == null ? null : storyDefOrNull(ref.story);
  final cp = d == null ? null : checkpointOf(d, ref!.cp);
  return cp?.title ?? 'STORY';
}

String storyArtOf(String id) {
  final ref = parseStorySession(id);
  final d = ref == null ? null : storyDefOrNull(ref.story);
  final cp = d == null ? null : checkpointOf(d, ref!.cp);
  return cp?.art ?? 'building';
}
