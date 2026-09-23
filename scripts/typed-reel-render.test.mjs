import assert from 'node:assert/strict';
import test from 'node:test';

process.env.mode = 'dev';

const { comp_container } = await import('../js-out/app.comp.container.mjs');
const { store } = await import('../js-out/app.schema.mjs');
const { new_reel, toggle_display } = await import('../js-out/reel.typed.mjs');
const { make_string } = await import('../js-out/respo.render.html.mjs');

test('renders the typed Reel devtools with an empty history', () => {
  const reel = toggle_display(new_reel(store));
  const html = make_string(comp_container(reel));

  assert.match(html, /placeholder="Content"/);
  assert.match(html, /Merge/);
  assert.match(html, /Reset/);
});
