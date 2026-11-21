/// Character constants. Stats are spent with level-up points; skills improve
/// by using them.
const statKeys = ['STR', 'END', 'AGI', 'INT', 'PER', 'LCK'];
const skillKeys = ['HACKING', 'LOCKPICKING', 'COMBAT', 'SCAVENGING', 'SURVIVAL', 'ENGINEERING'];

const statNames = {
  'STR': 'STRENGTH',
  'END': 'ENDURANCE',
  'AGI': 'AGILITY',
  'INT': 'INTELLIGENCE',
  'PER': 'PERCEPTION',
  'LCK': 'LUCK',
};

const maxStat = 10;
const maxSkill = 10;

/// XP needed to go from [level] to the next level.
int xpForLevel(int level) => 40 + 25 * (level - 1);

/// Skill XP needed to go from skill level [level] to the next.
int skillXpNeeded(int level) => 4 + 3 * level;
