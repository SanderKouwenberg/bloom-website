#!/usr/bin/env node
/**
 * Haalt de laatste Instagram-posts op en zet ze als gewone, zelf gehoste
 * afbeeldingen in de site. Draait bij het bouwen, niet in de browser van de
 * bezoeker — zo blijft de pagina vrij van externe aanvragen en cookies.
 *
 * Nodig in de omgeving:
 *   IG_TOKEN  — long-lived access token van het Instagram-account
 *   IG_LIMIT  — optioneel, aantal posts (standaard 3)
 *
 * Zonder token stopt het script zonder foutmelding en blijft de bestaande
 * inhoud van de pagina staan. Dat is bewust: een verlopen token mag nooit
 * een lege of kapotte sectie opleveren.
 */

import { readFile, writeFile, mkdir, readdir, unlink } from 'node:fs/promises';
import { existsSync } from 'node:fs';
import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import path from 'node:path';

const run = promisify(execFile);

const ROOT = path.resolve(import.meta.dirname, '..');
const IMG_DIR = path.join(ROOT, 'assets', 'img', 'instagram');
const DATA_FILE = path.join(ROOT, 'data', 'instagram.json');
const PAGE = path.join(ROOT, 'index.html');
const START = '<!-- instagram:start -->';
const END = '<!-- instagram:end -->';

const TOKEN = process.env.IG_TOKEN;
const LIMIT = Number(process.env.IG_LIMIT || 3);
const PROFILE = 'https://www.instagram.com/bloom_swf/';

if (!TOKEN) {
  console.log('Geen IG_TOKEN gevonden — de pagina blijft ongewijzigd.');
  process.exit(0);
}

/* ── Ophalen ─────────────────────────────────────────────────────────── */

async function fetchJson(url) {
  const res = await fetch(url);
  const body = await res.json();
  if (!res.ok) {
    const msg = body?.error?.message || res.statusText;
    throw new Error(`Instagram API gaf ${res.status}: ${msg}`);
  }
  return body;
}

async function fetchPosts() {
  const fields = 'id,caption,media_type,media_url,thumbnail_url,permalink,timestamp';
  const url = `https://graph.instagram.com/me/media?fields=${fields}&limit=${LIMIT * 2}&access_token=${TOKEN}`;
  const { data = [] } = await fetchJson(url);
  return data.filter((p) => p.media_url || p.thumbnail_url).slice(0, LIMIT);
}

/* ── Tekst opschonen ─────────────────────────────────────────────────── */

/**
 * Instagram-captions zitten vol hashtags en emoji. Die passen niet in de
 * typografie van de site, dus ze gaan eruit; de link naar de post laat de
 * originele tekst zien.
 */
function cleanCaption(raw) {
  if (!raw) return '';
  const text = raw
    .split('\n')
    .filter((line) => !/^\s*(#\S+\s*)+$/.test(line))
    .join(' ')
    .replace(/#\S+/g, '')
    .replace(/\p{Extended_Pictographic}/gu, '')
    .replace(/\s+/g, ' ')
    .trim();

  if (text.length <= 150) return text;
  const cut = text.slice(0, 150);
  const stop = Math.max(cut.lastIndexOf('. '), cut.lastIndexOf('? '), cut.lastIndexOf('! '));
  return stop > 60 ? cut.slice(0, stop + 1) : cut.replace(/\s\S*$/, '') + '…';
}

function dutchDate(iso) {
  return new Date(iso).toLocaleDateString('nl-NL', { day: 'numeric', month: 'long', year: 'numeric' });
}

function escapeHtml(s) {
  return s.replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
}

/* ── Afbeeldingen ────────────────────────────────────────────────────── */

async function saveImage(post) {
  const src = post.media_type === 'VIDEO' ? post.thumbnail_url : post.media_url;
  const res = await fetch(src);
  if (!res.ok) throw new Error(`Afbeelding ophalen mislukte (${res.status})`);
  const buffer = Buffer.from(await res.arrayBuffer());
  const file = path.join(IMG_DIR, `${post.id}.jpg`);
  await writeFile(file, buffer);

  // Verkleinen als ImageMagick beschikbaar is; anders het origineel houden.
  try {
    await run('magick', [file, '-resize', '900x900>', '-quality', '82', '-strip', file]);
  } catch {
    try {
      await run('convert', [file, '-resize', '900x900>', '-quality', '82', '-strip', file]);
    } catch {
      console.log('ImageMagick niet gevonden — afbeelding onverkleind opgeslagen.');
    }
  }
  return path.posix.join('assets/img/instagram', `${post.id}.jpg`);
}

async function removeStaleImages(keep) {
  if (!existsSync(IMG_DIR)) return;
  for (const name of await readdir(IMG_DIR)) {
    if (!keep.has(name)) await unlink(path.join(IMG_DIR, name));
  }
}

/* ── Het blok in de pagina ───────────────────────────────────────────── */

function renderSection(posts) {
  const cards = posts
    .map((p) => {
      const inner = [
        `<img src="${escapeHtml(p.image)}" alt="Instagram-bericht van BLOOM van ${escapeHtml(p.date)}" width="900" height="900" loading="lazy">`,
        ...(p.caption ? [`<p class="ig-card__text">${escapeHtml(p.caption)}</p>`] : []),
        `<p class="ig-card__date">${escapeHtml(p.date)}</p>`
      ]
        .map((line) => '            ' + line)
        .join('\n');

      return `        <li class="ig-card">
          <a class="ig-card__link" href="${escapeHtml(p.permalink)}" rel="noopener">
${inner}
          </a>
        </li>`;
    })
    .join('\n');

  return `${START}
  <section class="section" id="instagram">
    <div class="wrap reveal">
      <p class="eyebrow">Instagram</p>
      <div class="ig-head">
        <h2>Wat we delen</h2>
        <a class="link-under" href="${PROFILE}" rel="noopener">Volg @bloom_swf</a>
      </div>
      <ul class="ig-grid">
${cards}
      </ul>
    </div>
  </section>
  ${END}`;
}

/* ── Uitvoeren ───────────────────────────────────────────────────────── */

try {
  const raw = await fetchPosts();
  if (!raw.length) {
    console.log('Geen posts teruggekregen — de pagina blijft ongewijzigd.');
    process.exit(0);
  }

  await mkdir(IMG_DIR, { recursive: true });
  await mkdir(path.dirname(DATA_FILE), { recursive: true });

  const posts = [];
  for (const p of raw) {
    posts.push({
      id: p.id,
      permalink: p.permalink,
      caption: cleanCaption(p.caption),
      date: dutchDate(p.timestamp),
      timestamp: p.timestamp,
      image: await saveImage(p)
    });
  }

  await removeStaleImages(new Set(posts.map((p) => `${p.id}.jpg`)));
  await writeFile(DATA_FILE, JSON.stringify({ opgehaald: new Date().toISOString(), posts }, null, 2) + '\n');

  const page = await readFile(PAGE, 'utf8');
  const from = page.indexOf(START);
  const to = page.indexOf(END);
  if (from === -1 || to === -1) {
    throw new Error(`De markeringen ${START} / ${END} staan niet in index.html`);
  }
  const updated = page.slice(0, from) + renderSection(posts) + page.slice(to + END.length);
  await writeFile(PAGE, updated);

  console.log(`${posts.length} posts verwerkt.`);
} catch (err) {
  console.error('Ophalen mislukt:', err.message);
  console.error('De pagina is niet gewijzigd; de vorige posts blijven staan.');
  process.exit(1);
}
