import assert from 'node:assert/strict';
import test from 'node:test';

process.env.mode = 'dev';

const { comp_container } = await import('../js-out/app.comp.container.mjs');
const { store, decode_op, decode_store } = await import('../js-out/app.schema.mjs');
const { updater } = await import('../js-out/app.updater.mjs');
const { new_reel, toggle_display, record_op, refresh } = await import('../js-out/reel.typed.mjs');
const { make_string } = await import('../js-out/respo.render.html.mjs');
const clt = await import('../js-out/calcit.core.mjs');

// Fixed synthetic archive produced by the clean 0.27.0 tag's native formatter,
// using the pre-upgrade Store layout and format-cirru-edn writer. No user data.
const PRE_031_ARCHIVE = `
%{} 'Store $ :states $ {}
  :cursor $ []
  :data $ {} $ :content "|旧版合成存档🐈"
`;

test('renders the typed Reel devtools with an empty history', () => {
  const reel = toggle_display(new_reel(store));
  const html = make_string(comp_container(reel));

  assert.match(html, /placeholder="Content"/);
  assert.match(html, /Merge/);
  assert.match(html, /Reset/);
});

test('content edits survive Reel replay and the existing saved-state format', () => {
  const field = (value, key) => clt.get(value, clt.init_tags([key])[key]).extra[0];
  const wire = clt.parse_cirru_edn(':: :states ([]) ({} (:content |中文🐈))');
  const reel = record_op(updater, new_reel(store), decode_op(wire), 'edit', 1);
  const current = field(reel, 'store');
  assert.equal(field(field(field(current, 'states'), 'data'), 'content'), '中文🐈');
  assert.match(make_string(comp_container(reel)), /中文🐈/);
  const restored = clt.option_$o_unwrap(decode_store(clt.parse_cirru_edn(clt.format_cirru_edn(current))));
  assert.equal(clt.format_cirru_edn(restored), clt.format_cirru_edn(current));
  assert.equal(clt.option_$o_unwrap(decode_store(current)), current);
  assert.equal(clt.format_cirru_edn(field(refresh(updater, reel, store), 'store')), clt.format_cirru_edn(current));
  assert.equal(clt.option_$o_none_$q_(decode_store(clt.parse_cirru_edn('{} (:states $ {} (:cursor |wrong))'))), true);
  assert.equal(clt.option_$o_none_$q_(decode_store(clt.parse_cirru_edn(PRE_031_ARCHIVE.replace(':cursor $ []', ':cursor |wrong')))), true);
  assert.equal(clt.option_$o_some_$q_(decode_store(clt.parse_cirru_edn('{} (:states $ {})'))), true);
});

test('hydrates the fixed pre-upgrade archive through the typed Reel update path', () => {
  const field = (value, key) => clt.get(value, clt.init_tags([key])[key]).extra[0];
  const legacy = clt.parse_cirru_edn(PRE_031_ARCHIVE);
  const hydrate = clt._$o__$o_(clt.init_tags(['hydrate-storage'])['hydrate-storage'], legacy);
  const reel = record_op(updater, new_reel(store), decode_op(hydrate), 'legacy-archive', 1);
  const restored = field(reel, 'store');
  const expected = clt.assoc(store, clt.init_tags(['states']).states, field(legacy, 'states'));
  assert.equal(clt._$n__$e_(restored, expected), true);
  assert.equal(field(field(field(restored, 'states'), 'data'), 'content'), '旧版合成存档🐈');
  assert.equal(clt.format_cirru_edn(field(field(restored, 'states'), 'cursor')), clt.format_cirru_edn(clt.parse_cirru_edn('[]')));
  assert.match(make_string(comp_container(reel)), /旧版合成存档🐈/);
});
