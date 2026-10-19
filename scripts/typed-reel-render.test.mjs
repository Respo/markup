import assert from 'node:assert/strict';
import test from 'node:test';

process.env.mode = 'dev';

const { comp_container } = await import('../js-out/app.comp.container.mjs');
const { store, decode_op, decode_store } = await import('../js-out/app.schema.mjs');
const { updater } = await import('../js-out/app.updater.mjs');
const { new_reel, toggle_display, record_op, refresh } = await import('../js-out/reel.typed.mjs');
const { make_string } = await import('../js-out/respo.render.html.mjs');
const clt = await import('../js-out/calcit.core.mjs');

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
});
