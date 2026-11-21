import 'story_model.dart';
import 'stories/below.dart';
import 'stories/caravan.dart';
import 'stories/transmission.dart';
// Major expeditions
import 'stories/major/bakeoff.dart';
import 'stories/major/bigbrother.dart';
import 'stories/major/church.dart';
import 'stories/major/freezer.dart';
import 'stories/major/garys.dart';
import 'stories/major/giant.dart';
import 'stories/major/manufactured.dart';
import 'stories/major/moon.dart';
import 'stories/major/neighbourhood.dart';
import 'stories/major/radioknows.dart';
import 'stories/major/republic.dart';
import 'stories/major/salesman.dart';
import 'stories/major/waterheist.dart';
import 'stories/major/wedding.dart';
// Medium stories
import 'stories/medium/checkout.dart';
import 'stories/medium/shadow.dart';
// Short encounters and recurring characters
import 'stories/encounters/accountant.dart';
import 'stories/encounters/box.dart';
import 'stories/encounters/checkout_return.dart';
import 'stories/encounters/chicken.dart';
import 'stories/encounters/church_return.dart';
import 'stories/encounters/dj.dart';
import 'stories/encounters/doctor.dart';
import 'stories/encounters/frank.dart';
import 'stories/encounters/garys_return.dart';
import 'stories/encounters/grandma.dart';
import 'stories/encounters/huggins.dart';
import 'stories/encounters/inspector.dart';
import 'stories/encounters/invisible.dart';
import 'stories/encounters/lottery.dart';
import 'stories/encounters/murray.dart';
import 'stories/encounters/mushroom.dart';
import 'stories/encounters/retirement.dart';
import 'stories/encounters/shadow_return.dart';
import 'stories/encounters/shoes.dart';
import 'stories/encounters/shoes_return.dart';
import 'stories/encounters/timetraveller.dart';
import 'stories/encounters/toilet.dart';
import 'stories/encounters/toll.dart';

/// Every Story Expedition, in the order they are listed on the selection screen.
/// To add a story: write a [StoryDef] in stories/ and add it here.
/// (The selection screen groups them: major, medium, short. Follow-up
/// encounters unlock after the story they follow up on.)
final List<StoryDef> storyCatalog = [
  // ---- major expeditions
  transmissionStory,
  caravanStory,
  belowStory,
  churchStory,
  garysStory,
  manufacturedStory,
  waterheistStory,
  radioknowsStory,
  republicStory,
  neighbourhoodStory,
  bakeoffStory,
  bigbrotherStory,
  salesmanStory,
  giantStory,
  moonStory,
  freezerStory,
  weddingStory,
  // ---- medium stories
  checkoutStory,
  shadowStory,
  // ---- short stories and encounters
  shoesStory,
  tollStory,
  invisibleStory,
  chickenStory,
  doctorStory,
  timetravellerStory,
  inspectorStory,
  toiletStory,
  retirementStory,
  lotteryStory,
  djStory,
  mushroomStory,
  boxStory,
  // ---- recurring characters
  murrayStory,
  grandmaStory,
  hugginsStory,
  accountantStory,
  frankStory,
  // ---- follow-ups (unlock after the original)
  churchReturnStory,
  shoesReturnStory,
  checkoutReturnStory,
  garysReturnStory,
  shadowReturnStory,
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
