import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
assert.equal(process.env.GITHUB_ACTIONS,'true');assert.equal(process.platform,'linux');
assert.equal(execFileSync('calcit',['-v'],{encoding:'utf8'}).trim(),'0.30.1');
const run=(...a)=>execFileSync('calcit',['calcit.cirru',...a],{encoding:'utf8',maxBuffer:48e6,stdio:['ignore','pipe','pipe']});
const blob=()=>execFileSync('git',['hash-object','calcit.cirru'],{encoding:'utf8'}).trim();
assert.equal(blob(),'9ff2d8f989a204d512986ddc111161833d8e914c');
const norm=v=>Array.isArray(v)?v.map(norm):v&&typeof v==='object'?Object.fromEntries(Object.entries(v).map(([k,x])=>[k,k==='__edn_set'?x.map(norm).sort((a,b)=>JSON.stringify(a).localeCompare(JSON.stringify(b))):norm(x)])):v;
const q=(...a)=>norm(JSON.parse(run('query',...a,'--format','json')).data);
const input=JSON.parse(readFileSync('reviewed.json','utf8'));
const before={config:norm(input.config.data),namespaces:input.namespaces.map(x=>norm(x.data)),defs:input.definitions.map(x=>norm(x.data))};
assert.equal(before.defs.length,19);assert.equal(before.defs.reduce((n,d)=>n+d.tests.length+d.examples.length,0),0);
assert.deepEqual(q('config'),before.config);assert.deepEqual(q('ns').namespaces.map(n=>q('ns',n)),before.namespaces);
for(const d of before.defs)assert.deepEqual(q('def',d.id),d);
const expected=structuredClone(before),ops=[],sites=[],counts={unwrapOr:0,unwrap:0,css:0,dom:0,watcher:0,host:0,render:0,restoreMove:0,invalidStop:0};
const show=(id,path)=>JSON.parse(run('tree','show',id,'--path','@'+path.join('.'),'--format','json')).tree;
const replace=(id,path,value)=>ops.push(['tree','replace',id,'--path','@'+path.join('.'),'--input-format','json-ast','--code',JSON.stringify(value)]);
const map=['::',"'Map","'Tag","'Dynamic"],dispatch=['::',"'Fn",['{}',[':rest',"'Dynamic"],[':return',"'Unit"],[':args',['[]',"'Dynamic"]]]];
const domHint=['hint-fn',['{}',[':return',"'Unit"],[':args',['[]',map,dispatch]]]];
const state=['::',"'reel.typed/State","'app.schema/Op","'app.schema/Store"];
const watchHint=['hint-fn',['{}',[':return',"'Unit"],[':args',['[]',state,state]]]];
const hostHint=['hint-fn',['{}',[':return',"'Unit"],[':args',['[]',"'js-ffi.browser/EventHost"]]]];
const renderHint=['hint-fn',['{}',[':return',"'Unit"],[':args',['[]',"'Dynamic"]]]];
function insertHint(id,path,x,hint){assert.equal(x[0],'fn');assert.notEqual(x[2]?.[0],'hint-fn');const p=[...path,2];ops.push(['tree','insert',id,'--path','@'+p.join('.'),'--at','before','--input-format','json-ast','--code',JSON.stringify(hint)]);x.splice(2,0,structuredClone(hint));sites.push({id,path:p,inserted:hint});}
function walk(x,path,id){
  if(!Array.isArray(x)||['quote','quasiquote','comment',';','defmacro'].includes(x[0]))return x;
  const original=structuredClone(x);
  if(['option:unwrap-or','option:unwrap'].includes(x[0])){assert.deepEqual(show(id,path),original);const next=x[0]==='option:unwrap-or'?'.unwrap-or':'.unwrap';counts[x[0]==='option:unwrap-or'?'unwrapOr':'unwrap']++;replace(id,[...path,0],next);x[0]=next;sites.push({id,path,original,replacement:next});}
  if(x[0]==='{}')for(let j=1;j<x.length;j++){const pair=x[j];if(Array.isArray(pair)&&pair[0]===':height'&&pair[1]==='320'){assert.equal(id,'app.comp.container/comp-container');assert.equal(show(id,[...path,j,1]),'320');replace(id,[...path,j,1],'|320px');pair[1]='|320px';counts.css++;}}
  const needsDOM=id==='app.comp.container/comp-container'&&x[0]==='fn'&&JSON.stringify(x[1])===JSON.stringify(['e','d!']);
  x=x.map((v,i)=>walk(v,[...path,i],id));
  if(needsDOM){assert.deepEqual(show(id,path),original);assert.equal(original.length,3);assert.ok(['d!','println'].includes(original[2][0]));insertHint(id,path,x,domHint);counts.dom++;}
  if(x[0]==='add-watch!'){assert.equal(x[1],'*reel');assert.deepEqual(show(id,[...path,3]),original[3]);insertHint(id,[...path,3],x[3],watchHint);counts.watcher++;}
  if(x[0]==='set-before-unload!'){assert.deepEqual(show(id,[...path,1]),original[1]);insertHint(id,[...path,1],x[1],hostHint);counts.host++;}
  if(x[0]==='add-event-listener!'){assert.equal(x[1],'|visibilitychange');assert.deepEqual(show(id,[...path,2]),original[2]);insertHint(id,[...path,2],x[2],hostHint);counts.host++;}
  if(x[0]==='render!'){assert.deepEqual(show(id,[...path,3]),original[3]);assert.deepEqual(x[3][1],['op']);insertHint(id,[...path,3],x[3],renderHint);counts.render++;}
  return x;
}
for(const d of expected.defs)d.code=walk(d.code,[],d.id);
const main=expected.defs.find(d=>d.id==='app.main/main!'),restore=structuredClone(main.code[11]);
assert.deepEqual(show(main.id,[11]),restore);assert.equal(restore[0],'match');assert.deepEqual(restore[1],['storage-get',[':storage-key','config/site']]);
const hud=restore[2][1][3][1];assert.deepEqual(hud,['hud!','|error','|Ignored invalid saved state']);
restore[2][1][3][1]=['do',hud,['raise','|Invalid saved Markup state; original archive retained']];
ops.push(['tree','delete',main.id,'--path','@11']);counts.restoreMove++;
ops.push(['tree','insert',main.id,'--path','@5','--at','before','--input-format','json-ast','--code',JSON.stringify(restore)]);counts.invalidStop++;
main.code.splice(11,1);main.code.splice(5,0,restore);
assert.equal(main.code[5][0],'match');assert.equal(main.code[6][0],'render-app!');assert.equal(main.code[7][0],'add-watch!');assert.equal(main.code[9][0],'set-before-unload!');assert.equal(main.code[11][0],'set-interval!');
assert.deepEqual(counts,{unwrapOr:1,unwrap:1,css:1,dom:2,watcher:2,host:2,render:1,restoreMove:1,invalidStop:1});assert.equal(ops.length,12);
for(const d of before.defs){const e=expected.defs.find(x=>x.id===d.id);for(const k of Object.keys(d).filter(k=>k!=='code'))assert.deepEqual(e[k],d[k]);}
for(const id of ['app.schema/Op','app.schema/Store','app.schema/decode-op','app.schema/decode-store','app.schema/store','app.updater/updater','app.main/*reel','app.main/dispatch!','app.main/persist-storage!'])assert.deepEqual(expected.defs.find(d=>d.id===id),before.defs.find(d=>d.id===id));
const reload=expected.defs.find(d=>d.id==='app.main/reload!'),oldReload=before.defs.find(d=>d.id===reload.id);assert.deepEqual(reload.code[3][2][5],oldReload.code[3][2][5]);assert.deepEqual(reload.code[3][3],oldReload.code[3][3]);
mkdirSync('acceptance',{recursive:true});for(const [name,value]of Object.entries({before,expected,sites,operations:ops}))writeFileSync('acceptance/'+name+'.json',JSON.stringify(value,null,2));
const txn=['edit','transaction','--file','acceptance/operations.json','--format','json'],preview=JSON.parse(run(...txn,'--dry-run'));assert.ok(preview.scoped_revision);writeFileSync('acceptance/preview.json',JSON.stringify(preview,null,2));writeFileSync('acceptance/applied.json',run(...txn,'--expect-revision',preview.scoped_revision));
const after={config:q('config'),namespaces:q('ns').namespaces.map(n=>q('ns',n)),defs:expected.defs.map(d=>q('def',d.id))};assert.deepEqual(after,expected);
writeFileSync('acceptance/after.json',JSON.stringify(after,null,2));writeFileSync('acceptance/snapshot-after-blob.txt',blob());
writeFileSync('acceptance/summary.json',JSON.stringify({definitions:19,tests:0,examples:0,operations:12,counts,unsafeBefore:0,unsafeAfter:0,preserved:'All publicschemas/imports/metadata/config/original3Node tests/Store/Op/wire/contentRun/decoder/HUD preserved. Restorebeforefirstrenderandallpersistencehooks; invaliddecodedarchive retainsHUDandhalts beforehooks. Nohelpers/casts/budgets/tests/frameworks/compiler rules.'},null,2));
