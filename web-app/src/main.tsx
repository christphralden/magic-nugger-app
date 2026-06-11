import ReactDOM from "react-dom/client";

// if (import.meta.env.PROD && "serviceWorker" in navigator) {
//   navigator.serviceWorker.register("/unity-worker.js", { type: "module" });
// }
import { Provider } from "react-redux";
import { RouterProvider } from "react-router-dom";
import { store } from "@/store";
import { router } from "@/App";
import { Toaster } from "@/components/ui/sonner";
import "./index.css";

ReactDOM.createRoot(document.getElementById("root")!).render(
  // <React.StrictMode>
  <Provider store={store}>
    <RouterProvider router={router} />
    <Toaster duration={7000} />
  </Provider>,
  // </React.StrictMode>,
);
