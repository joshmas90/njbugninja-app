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

  form.querySelectorAll('input[name="service"]').forEach(input => {
    input.addEventListener('change', () => form.querySelector('.service-picker')?.removeAttribute('aria-invalid'));
  });

  form.addEventListener('submit', event => {
    event.preventDefault();
    if (!form.reportValidity()) return;

    const d = new FormData(form);
    const services = d.getAll('service').map(value => String(value).trim()).filter(Boolean);
    const servicePicker = form.querySelector('.service-picker');
    if (!services.length) {
      servicePicker?.setAttribute('aria-invalid', 'true');
      status.textContent = 'Select at least one service, or choose “Not sure / discuss my property.”';
      form.querySelector('input[name="service"]')?.focus();
      return;
    }
    servicePicker?.removeAttribute('aria-invalid');

    const msg =
      `Hi Mosquito Ninja, I'd like a property quote.\n\n` +
      `Name: ${d.get('name') || ''}\n` +
      `Phone: ${d.get('phone') || ''}\n` +
      `Town/ZIP: ${d.get('location') || ''}\n` +
      `Services: ${services.join(', ')}\n` +
      `Property type: ${d.get('propertyType') || 'Residential'}\n` +
      `Property details: ${d.get('message') || ''}`;

    status.textContent =
      'Review the prepared request, then tap Send in Messages. If texting is unavailable, choose the email or website option. Nothing is sent automatically.';

    window.location.href = `sms:+16093136317?&body=${encodeURIComponent(msg)}`;
  });
}
