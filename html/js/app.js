/**
 * ec_outfitbag — NUI Panel (Outfit-Liste im Taschen-Innenfach)
 * ---------------------------------------------------------------------------
 * Locale-Strings kommen vom Client via SendNUIMessage → data.locale (ui-Tabelle).
 * Fallback: DEFAULT_LOCALE (Englisch) für Browser-Vorschau ohne FiveM.
 */

const DEFAULT_LOCALE = {
    close: 'Close',
    apply: 'Wear',
    edit: 'Edit',
    edit_tip: 'Edit outfit name',
    delete: 'Delete',
    save: 'Save',
    save_tip: 'Save current outfit',
    badge_default: 'Select',
    badge_selected: 'Selected',
    badge_active: 'Active',
    badge_empty: '—',
    empty_slot: 'Empty',
    outfit_slot: 'Outfit %s',
    holo_preview: 'Preview',
    holo_none: 'No outfit selected',
    holo_toggle: '3D hologram',
    holo_on: 'Hologram on',
    holo_off: 'Hologram off',
    cat: { head: 'Head', body: 'Torso', legs: 'Legs', feet: 'Feet', misc: 'Extra' },
};

const HOLO_STORAGE_KEY = 'ec_outfitbag_holo';

const ICONS = {
    shirt: '<path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z"/>',
    mask: '<circle cx="12" cy="10" r="3"/><path d="M12 13c-4 0-7 2-7 5v2h14v-2c0-3-3-5-7-5z"/>',
    briefcase: '<rect x="2" y="7" width="20" height="14" rx="2"/><path d="M16 7V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v2"/>',
    plus: '<line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>',
};

const app            = document.getElementById('app');
const outfitList     = document.getElementById('outfitList');
const slotCounter    = document.getElementById('slotCounter');

const btnClose  = document.getElementById('btnClose');
const btnHoloToggle = document.getElementById('btnHoloToggle');
const btnApply  = document.getElementById('btnApply');
const btnEdit   = document.getElementById('btnEdit');
const btnDelete = document.getElementById('btnDelete');
const btnSave   = document.getElementById('btnSave');
const uiTooltip = document.getElementById('uiTooltip');
const hologramZone = document.getElementById('hologramZone');
const holoLabel    = document.getElementById('holoLabel');
const holoName     = document.getElementById('holoName');
const holoMeta     = document.getElementById('holoMeta');
const categoryBtns = document.querySelectorAll('.cat-btn');

const DEFAULT_SLOTS = 5;

let locale = { ...DEFAULT_LOCALE, cat: { ...DEFAULT_LOCALE.cat } };

let state = {
    maxSlots: DEFAULT_SLOTS,
    outfits: [],
    selectedSlot: null,
    activeSlot: null,
    category: 'head',
    holoEnabled: true,
};

/** string.format-Ersatz: ui.outfit_slot mit %s */
function t(key, ...args) {
    const parts = key.split('.');
    let value = locale;
    for (const part of parts) {
        value = value?.[part];
    }
    if (typeof value !== 'string') return key;
    if (args.length === 0) return value;
    let i = 0;
    return value.replace(/%s/g, () => String(args[i++]));
}

function getBadges() {
    return {
        default:  locale.badge_default  || DEFAULT_LOCALE.badge_default,
        selected: locale.badge_selected || DEFAULT_LOCALE.badge_selected,
        active:   locale.badge_active   || DEFAULT_LOCALE.badge_active,
    };
}

/** Wendet Locale auf statische UI-Elemente an (Tooltips, Labels). */
function applyLocale() {
    document.documentElement.lang = state.language || 'de';

    btnClose.dataset.tip = t('close');
    btnClose.setAttribute('aria-label', t('close'));

    const tipTargets = document.querySelectorAll('.tip-target');
    const actionTips = ['apply', 'edit_tip', 'delete'];
    tipTargets.forEach((el, i) => {
        const text = t(actionTips[i]);
        el.dataset.tip = text;
        const btn = el.querySelector('button');
        if (btn) btn.setAttribute('aria-label', text);
    });

    categoryBtns.forEach(btn => {
        const cat = btn.dataset.category;
        if (cat && locale.cat?.[cat]) {
            btn.dataset.tip = locale.cat[cat];
        }
    });

    btnSave.dataset.tip = t('save_tip');
    btnSave.setAttribute('aria-label', t('save_tip'));
    const saveLabel = btnSave.querySelector('span');
    if (saveLabel) saveLabel.textContent = t('save');

    updateHoloToggleUi();
}

function readStoredHoloPreference(fallback) {
    try {
        var stored = localStorage.getItem(HOLO_STORAGE_KEY);
        if (stored === '1') return true;
        if (stored === '0') return false;
    } catch (err) {}
    return fallback !== false;
}

function persistHoloPreference(enabled) {
    try {
        localStorage.setItem(HOLO_STORAGE_KEY, enabled ? '1' : '0');
    } catch (err) {}
}

function updateHoloToggleUi() {
    if (!btnHoloToggle) return;

    const on = state.holoEnabled !== false;
    btnHoloToggle.classList.toggle('is-on', on);
    btnHoloToggle.setAttribute('aria-pressed', on ? 'true' : 'false');
    btnHoloToggle.dataset.tip = on ? t('holo_on') : t('holo_off');
    btnHoloToggle.setAttribute('aria-label', t('holo_toggle'));
}

window.addEventListener('message', ({ data }) => {
    if (data.action === 'open') {
        loadData(data.data);
        app.classList.remove('hidden');
    }
    if (data.action === 'update') {
        loadData(data.data);
    }
    if (data.action === 'close') {
        app.classList.add('hidden');
        resetState();
    }
});

document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && !app.classList.contains('hidden')) closeUI();
});

function loadData(data) {
    if (data?.locale) {
        locale = { ...DEFAULT_LOCALE, ...data.locale, cat: { ...DEFAULT_LOCALE.cat, ...data.locale.cat } };
    }
    state.language = data?.language;
    applyLocale();

    state.maxSlots = data.maxSlots || DEFAULT_SLOTS;
    state.outfits = data.outfits || [];
    state.activeSlot = data.activeOutfit || null;

    if (data.holoDefault !== undefined && localStorage.getItem(HOLO_STORAGE_KEY) === null) {
        state.holoEnabled = data.holoDefault !== false;
    } else {
        state.holoEnabled = readStoredHoloPreference(data.holoDefault !== false);
    }

    nuiPost('setHoloEnabled', { enabled: state.holoEnabled });

    const prevSelected = state.selectedSlot;
    state.selectedSlot = state.outfits.find(o => o.state === 'selected')?.slot
        ?? (state.outfits.some(o => o.slot === prevSelected && o.name) ? prevSelected : null)
        ?? state.activeSlot
        ?? null;

    render();
}

function resetState() {
    state = {
        maxSlots: DEFAULT_SLOTS,
        outfits: [],
        selectedSlot: null,
        activeSlot: null,
        category: 'head',
        holoEnabled: readStoredHoloPreference(true),
        language: state.language,
    };
}

function render() {
    const filled = state.outfits.filter(o => o.name).length;
    slotCounter.textContent = `${filled}/${state.maxSlots}`;

    renderOutfits();
    updateActions();
    updateHoloToggleUi();
}

function getSlotState(slot) {
    if (slot === state.activeSlot) return 'active';
    if (slot === state.selectedSlot) return 'selected';
    return 'default';
}

function renderOutfits() {
    outfitList.innerHTML = '';
    const badges = getBadges();

    for (let i = 1; i <= state.maxSlots; i++) {
        outfitList.appendChild(createCard(i, state.outfits.find(o => o.slot === i), badges));
    }

    requestAnimationFrame(updateScrollState);
}

function updateScrollState() {
    const canScroll = outfitList.scrollHeight > outfitList.clientHeight + 1;
    outfitList.classList.toggle('is-scrollable', canScroll);
}

function createCard(slotNum, outfit, badges) {
    const el = document.createElement('div');
    el.className = 'outfit-card';

    if (!outfit?.name) {
        el.classList.add('empty');
        el.innerHTML = `
            <div class="card-icon card-icon--empty">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">${ICONS.plus}</svg>
            </div>
            <div class="card-info">
                <span class="card-name">${escapeHtml(t('empty_slot'))}</span>
                <span class="card-slot">${escapeHtml(t('outfit_slot', slotNum))}</span>
            </div>
            <span class="card-badge">${locale.badge_empty || DEFAULT_LOCALE.badge_empty}</span>`;
        return el;
    }

    const slotState = getSlotState(slotNum);
    if (slotState !== 'default') el.classList.add(slotState);

    const color = outfit.color || 'red';
    const icon = ICONS[outfit.icon] || ICONS.shirt;

    el.innerHTML = `
        <div class="card-icon card-icon--${color}">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">${icon}</svg>
        </div>
        <div class="card-info">
            <span class="card-name">${escapeHtml(outfit.name)}</span>
            <span class="card-slot">${escapeHtml(t('outfit_slot', slotNum))}</span>
        </div>
        <span class="card-badge">${badges[slotState]}</span>`;

    el.addEventListener('click', () => selectSlot(slotNum));
    return el;
}

function selectSlot(slotNum) {
    const outfit = state.outfits.find(o => o.slot === slotNum);
    if (!outfit?.name) return;
    state.selectedSlot = slotNum;
    render();
    nuiPost('selectOutfit', { slot: slotNum });
}

function updateActions() {
    const has = state.selectedSlot !== null
        && state.outfits.some(o => o.slot === state.selectedSlot && o.name);

    btnApply.disabled  = !has;
    btnEdit.disabled   = !has;
    btnDelete.disabled = !has;
}

function closeUI() {
    hideTooltip();
    app.classList.add('hidden');
    nuiPost('close');
}

btnClose.addEventListener('click', closeUI);

if (btnHoloToggle) {
    btnHoloToggle.addEventListener('click', () => {
        state.holoEnabled = !state.holoEnabled;
        persistHoloPreference(state.holoEnabled);
        updateHoloToggleUi();
        nuiPost('setHoloEnabled', { enabled: state.holoEnabled });
        if (state.holoEnabled && state.selectedSlot) {
            nuiPost('selectOutfit', { slot: state.selectedSlot });
        }
    });
}

btnApply.addEventListener('click', () => {
    if (!state.selectedSlot) return;
    state.activeSlot = state.selectedSlot;
    render();
    nuiPost('applyOutfit', { slot: state.selectedSlot });
});

btnEdit.addEventListener('click', () => {
    if (!state.selectedSlot) return;
    nuiPost('editOutfit', { slot: state.selectedSlot });
});

btnDelete.addEventListener('click', () => {
    if (!state.selectedSlot) return;
    nuiPost('deleteOutfit', { slot: state.selectedSlot });
});

btnSave.addEventListener('click', () => nuiPost('saveOutfit'));

function showTooltip(el) {
    const text = el.dataset.tip;
    if (!text) return;

    uiTooltip.textContent = text;
    uiTooltip.classList.remove('hidden');

    requestAnimationFrame(() => {
        const rect = el.getBoundingClientRect();
        const tipRect = uiTooltip.getBoundingClientRect();
        const gap = 8;
        let left = rect.left + rect.width / 2;
        let top = rect.top - gap;

        const pad = 6;
        const half = tipRect.width / 2;
        left = Math.max(pad + half, Math.min(window.innerWidth - pad - half, left));
        top = Math.max(pad + tipRect.height, top);

        uiTooltip.style.left = `${left}px`;
        uiTooltip.style.top = `${top}px`;
        uiTooltip.classList.add('visible');
    });
}

function hideTooltip() {
    uiTooltip.classList.remove('visible');
    uiTooltip.classList.add('hidden');
}

document.querySelectorAll('[data-tip]').forEach(el => {
    el.addEventListener('mouseenter', () => showTooltip(el));
    el.addEventListener('mouseleave', hideTooltip);
    el.addEventListener('focus', () => showTooltip(el));
    el.addEventListener('blur', hideTooltip);
});

categoryBtns.forEach(btn => {
    btn.addEventListener('click', () => {
        categoryBtns.forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        state.category = btn.dataset.category;
        nuiPost('setCategory', { category: state.category });
    });
});

function nuiPost(action, data = {}) {
    fetch(`https://ec_outfitbag/${action}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
    }).catch(() => {});
}

function escapeHtml(str) {
    const d = document.createElement('div');
    d.textContent = str;
    return d.innerHTML;
}

applyLocale();

if (!window.invokeNative) {
    document.body.classList.add('browser-preview');
    locale = {
        close: 'Schließen', apply: 'Anziehen', edit: 'Bearbeiten', edit_tip: 'Outfit-Namen bearbeiten', delete: 'Löschen',
        save: 'Speichern', save_tip: 'Aktuelles Outfit speichern',
        badge_default: 'Wählen', badge_selected: 'Gewählt', badge_active: 'Aktiv', badge_empty: '—',
        empty_slot: 'Leer', outfit_slot: 'Outfit %s',
        holo_preview: 'Vorschau', holo_none: 'Kein Outfit gewählt',
        holo_toggle: '3D-Hologramm', holo_on: 'Hologramm an', holo_off: 'Hologramm aus',
        cat: { head: 'Kopf', body: 'Torso', legs: 'Beine', feet: 'Füße', misc: 'Extra' },
    };
    applyLocale();
    loadData({
        maxSlots: 5,
        language: 'de',
        outfits: [
            { slot: 1, name: 'SWAT Gear', icon: 'shirt', color: 'red' },
            { slot: 2, name: 'Heist', icon: 'mask', color: 'red' },
            { slot: 3, name: 'Work', icon: 'briefcase', color: 'blue' },
        ],
        activeOutfit: null,
    });
    state.selectedSlot = 2;
    app.classList.remove('hidden');
    render();
}
