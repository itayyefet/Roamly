/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_AAD_CLIENT_ID: string;
  readonly VITE_AAD_AUTHORITY?: string;
  readonly VITE_REDIRECT_URI?: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
