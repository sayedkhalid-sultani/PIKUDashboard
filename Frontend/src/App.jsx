import "./App.css";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import Spinner from "./components/shared/Spinner";
import AppRouter from "./routes/AppRouter";
import { BrowserRouter } from "react-router-dom";
import { ToastContainer } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";
import AuthRefreshGate from "./components/shared/AuthRefreshGate";
import { Suspense } from "react";

const queryClient = new QueryClient();

function App() {
  return (
    <>
      <QueryClientProvider client={queryClient}>
        <BrowserRouter>
          <AuthRefreshGate />
          <Spinner />

          <Suspense
            fallback={<div className="p-6 text-slate-500">Loading…</div>}
          >
            <AppRouter />
          </Suspense>
          <ToastContainer
            position="top-right"
            autoClose={2000}
            theme="colored"
          />
        </BrowserRouter>
      </QueryClientProvider>
    </>
  );
}

export default App;
