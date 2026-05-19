import { type ReactNode } from "react";
import { useNavigate, useMatch, Outlet } from "react-router-dom";
import { CartoonButton } from "@/components/ui/cartoon-button";
import { Typography } from "@/components/ui/typography";
import { PageLayout } from "@/components/layout/page-layout";

function AdminNavButton({ to, children }: { to: string; children: ReactNode }) {
  const navigate = useNavigate();
  const match = useMatch(to);
  return (
    <CartoonButton
      className="rounded-xl font-body justify-start"
      size={"sm"}
      variant={match ? "select" : "ghost"}
      onClick={() => navigate(to)}
    >
      {children}
    </CartoonButton>
  );
}

export function AdminLayout() {
  return (
    <PageLayout title="Admin">
      <div className="w-full flex gap-8 h-full ">
        <div className="w-1/6 h-full flex flex-col overflow-hidden shrink-0">
          <div className="flex flex-col h-full gap-8">
            <Typography variant="subheading">Admin</Typography>
            <div className="flex flex-col gap-2 flex-1">
              <AdminNavButton to="/admin/dashboard">Dashboard</AdminNavButton>
              <AdminNavButton to="/admin/players">Players</AdminNavButton>
              <AdminNavButton to="/admin/sessions">Sessions</AdminNavButton>
              <AdminNavButton to="/admin/levels">Levels</AdminNavButton>
              <AdminNavButton to="/admin/levels/create">
                Create Level
              </AdminNavButton>
              <AdminNavButton to="/admin/system">System</AdminNavButton>
            </div>
          </div>
        </div>

        <div className="w-full flex flex-col gap-4 overflow-y-auto">
          <Outlet />
        </div>
      </div>
    </PageLayout>
  );
}
