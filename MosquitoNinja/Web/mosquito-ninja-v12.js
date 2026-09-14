// Mosquito Ninja V21 runtime refinements.
// Loads the corrective stylesheet site-wide without requiring duplicate edits
// across every static HTML page.

const ensureHeadLink = (rel, href, attrs = {}) => {
  if (!document.head || document.querySelector(`link[rel="${rel}"][href="${href}"]`)) return;
  const link = document.createElement('link');
  link.rel = rel;
  link.href = href;
  Object.entries(attrs).forEach(([key, value]) => link.setAttribute(key, value));
  document.head.appendChild(link);
};

ensureHeadLink('stylesheet', './mosquito-ninja-v21-fixes.css');
// Native iOS app: no web manifest link required.

const y = document.querySelector('#year');
if (y) y.textContent = new Date().getFullYear();

const header = document.querySelector('.site-header');
if (header) {
  const syncHeader = () => header.classList.toggle('is-stuck', window.scrollY > 24);
  syncHeader();
  window.addEventListener('scroll', syncHeader, { passive: true });
}

const toggle = document.querySelector('.menu-toggle');
const nav = document.querySelector('#nav');
if (toggle && nav) {
  const setMenuOpen = open => {
    toggle.setAttribute('aria-expanded', String(open));
    nav.classList.toggle('open', open);
  };

  toggle.addEventListener('click', () => {
    setMenuOpen(toggle.getAttribute('aria-expanded') !== 'true');
  });

  nav.querySelectorAll('a').forEach(link => {
    link.addEventListener('click', () => setMenuOpen(false));
  });

  document.addEventListener('keydown', event => {
    if (event.key === 'Escape' && toggle.getAttribute('aria-expanded') === 'true') {
      setMenuOpen(false);
      toggle.focus();
    }
  });
}

const form = document.querySelector('#quote-form');
if (form) {
  let status = document.querySelector('#quote-status');
  if (!status) {
    status = document.createElement('p');
    status.id = 'quote-status';
    status.className = 'quote-status';
    status.setAttribute('role', 'status');
    status.setAttribute('aria-live', 'polite');

    const note = form.querySelector('.form-note');
    if (note) form.insertBefore(status, note);
    else form.appendChild(status);
  }

  form.addEventListener('submit', event => {
    event.preventDefault();
    if (!form.reportValidity()) return;

    const d = new FormData(form);
    const msg =
      `Hi Mosquito Ninja, I'd like a property quote.\n\n` +
      `Name: ${d.get('name') || ''}\n` +
      `Phone: ${d.get('phone') || ''}\n` +
      `Town/ZIP: ${d.get('location') || ''}\n` +
      `Service: ${d.get('service') || ''}\n` +
      `Property: ${d.get('message') || ''}`;

    status.textContent =
      'Opening your messaging app. If it does not open, call or text 609-313-6317 directly.';

    window.location.href = `sms:+16093136317?&body=${encodeURIComponent(msg)}`;
  });
}
