/**
 * Local, static draw.io configuration.
 *
 * TLS is terminated by the reverse proxy. Diagrams are opened from and saved
 * to the user's device, and integrations that require external services are
 * disabled.
 */
window.DRAWIO_PUBLIC_BUILD = true;
window.EXPORT_URL = null;
window.DRAWIO_BASE_URL = null;
window.DRAWIO_VIEWER_URL = null;
window.DRAWIO_LIGHTBOX_URL = null;
window.DRAW_MATH_URL = 'math4/es5';
window.DRAWIO_CONFIG = {
  lockdown: true,
  enableExportUrl: false,
  override: true,
  // This is a configuration schema revision, not the draw.io release.
  // Increment it only when browser-stored settings must be reset.
  version: 'homelab-static-v1'
};

urlParams['local'] = '1';
urlParams['plugins'] = '0';
urlParams['sync'] = 'manual';
urlParams['gapi'] = '0';
urlParams['db'] = '0';
urlParams['od'] = '0';
urlParams['ms365'] = '0';
urlParams['tr'] = '0';
urlParams['gh'] = '0';
urlParams['gl'] = '0';
