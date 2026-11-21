import '../../story_model.dart';
import '../story_kit.dart';

// THE ACCOUNTANT. Records every debt, transaction and favour. Reads the
// persistent world state, so any finished story can leave something on the
// ledger. Facts he knows about (all optional): debt.salesman, debt.checkout,
// debt.church, debt.gary, favour.gary, favour.frank, favour.murray, favour.grim,
// plus how stories ended.

class Accountant {
  /// One ledger line per thing he remembers. Always returns at least one.
  static List<String> ledger(StoryCtx c) {
    final l = <String>[
      if (known(c, 'debt.salesman'))
        '#ITEM: ONE (1) “MIRACLE TONIC”, TAKEN ON CREDIT FROM A TRAVELLING SALESMAN. INTEREST: ACCRUING. SALESMAN: NOT AWARE I KNOW.',
      if (known(c, 'debt.checkout'))
        '#ITEM: STOCK REMOVED FROM A SUPERMARKET WITHOUT A LOYALTY CARD. A ROBOT WAS WATCHING. SO WAS I.',
      if (known(c, 'debt.church'))
        '#ITEM: DONATION TO A CAR BATTERY. OUTSTANDING: ONE (1) BLESSING.',
      if (known(c, 'debt.gary')) '#ITEM: ONE (1) SHOE-RELATED LIE, TOLD TO A MAN CALLED GARY.',
      if (known(c, 'favour.gary')) '#FAVOUR OWED TO YOU: GARY’S GRATITUDE. VALUE: A SINGLE SHOE.',
      if (known(c, 'favour.murray')) '#FAVOUR OWED TO YOU: ONE (1) CARD TRICK, MURRAY PROMISED IT WOULD WORK.',
      if (known(c, 'favour.frank')) '#FAVOUR OWED TO YOU: FREQUENCY FRANK’S UNDYING (AND INACCURATE) LOYALTY.',
      if (known(c, 'favour.grim')) '#FAVOUR OWED BY YOU: DOLORES, THE SHOTGUN, WAS LENT TO YOU ONCE. SHE REMEMBERS.',
      if (c.ending('church') != null) '#NOTE: PRESENT AT A SERMON TO A CAR BATTERY. DID NOT TIP.',
      if (c.ending('garys') != null) '#NOTE: ONE OR MORE MEN CALLED GARY. ALL OF THEM CLAIMED PRIORITY. TOTAL OWED TO YOU: TOO MANY TO COUNT.',
      if (c.ending('waterheist') != null) '#NOTE: THE MAYOR OWES THE TOWN ONE (1) POOL’S WORTH OF WATER. NOBODY HAS ASKED HIM TO PAY.',
    ];
    if (l.isEmpty) {
      return [
        '#NO ENTRIES FOR YOU YET. THIS IS A COMPLIMENT. IT WILL NOT LAST.',
      ];
    }
    return l;
  }
}
