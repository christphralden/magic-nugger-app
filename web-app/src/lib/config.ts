declare global {
  interface Window {
    __CONFIG__: {
      webServerUrl: string;
      apiUrl: string;
    };
  }
}

export const config = window.__CONFIG__;
