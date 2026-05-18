import { type ReactNode } from "react";
import { z } from "zod";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { LogOut, Save } from "lucide-react";
import { useNavigate, useMatch, Outlet } from "react-router-dom";
import { useDispatch, useSelector } from "@/store/hooks";
import { selectCurrentPlayer } from "@/feature/auth/state/auth.slice";
import { selectPlayerLoading } from "@/feature/player/state/player.slice";
import { patchPlayer } from "@/feature/player/state/player.thunk";
import { PageLayout } from "@/components/layout/page-layout";
import { CartoonInput } from "@/components/ui/cartoon-input";
import { CartoonSelect } from "@/components/ui/cartoon-select";
import { CartoonButton } from "@/components/ui/cartoon-button";
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Typography } from "@/components/ui/typography";
import { GRADES } from "@/constants/grades";
import { toastError } from "@/lib/toast";
import type { RequestUpdatePlayer } from "@magic-nugger-app/shared";
import { StatCard } from "@/components/ui/stats-card";

const profileFormSchema = z.object({
  username: z
    .string()
    .min(3, "At least 3 characters")
    .max(32, "Too long")
    .optional(),
  display_name: z.string().max(64, "Too long").optional(),
  age: z
    .string()
    .regex(/^\d+$/, "Must be a number")
    .refine((v) => Number(v) >= 1, "Invalid age")
    .optional()
    .or(z.literal("")),
  grade: z.string().optional(),
  guardian_email: z
    .string()
    .email("Enter a valid email")
    .optional()
    .or(z.literal("")),
});

type ProfileFormValues = z.infer<typeof profileFormSchema>;

function SettingsNavButton({
  to,
  children,
}: {
  to: string;
  children: ReactNode;
}) {
  const navigate = useNavigate();
  const match = useMatch(to);
  return (
    <CartoonButton
      className="rounded-xl justify-start"
      variant={match ? "select" : "ghost"}
      onClick={() => navigate(to)}
    >
      {children}
    </CartoonButton>
  );
}

function SettingsLayout() {
  const navigate = useNavigate();

  return (
    <PageLayout title="Settings">
      <div className="w-full flex gap-8 h-[85vh]">
        <div className="w-1/6 h-full shrink-0">
          <div className="flex flex-col h-full gap-8">
            <Typography variant="subheading">Settings</Typography>
            <div className="flex flex-col gap-2 flex-1">
              <SettingsNavButton to="/settings/profile">
                Profile
              </SettingsNavButton>
              <SettingsNavButton to="/settings/statistics">
                Statistics
              </SettingsNavButton>
            </div>
            <CartoonButton
              variant="ghost"
              onClick={() => navigate("/logout")}
              className="bg-transparent text-coral rounded-lg"
            >
              <LogOut size={28} />
              Logout
            </CartoonButton>
          </div>
        </div>

        <div className="w-full flex flex-col gap-4">
          <Outlet />
        </div>
      </div>
    </PageLayout>
  );
}

export function ProfileTab() {
  const dispatch = useDispatch();
  const player = useSelector(selectCurrentPlayer)!;
  const loading = useSelector(selectPlayerLoading);

  const form = useForm<ProfileFormValues>({
    resolver: zodResolver(profileFormSchema),
    defaultValues: {
      username: player.username,
      display_name: player.display_name ?? "",
      age: player.age?.toString() ?? "",
      grade: player.grade?.toString() ?? "",
      guardian_email: player.guardian_email ?? "",
    },
  });

  const onSubmit = async (values: ProfileFormValues) => {
    const body: RequestUpdatePlayer = {};
    if (values.username) body.username = values.username;
    if (values.display_name) body.display_name = values.display_name;
    if (values.age) body.age = parseInt(values.age, 10);
    if (values.grade) body.grade = parseInt(values.grade, 10);
    if (values.guardian_email) body.guardian_email = values.guardian_email;

    const result = await dispatch(patchPlayer({ body }));
    if (patchPlayer.fulfilled.match(result)) {
      form.reset(values);
    } else {
      toastError((result.payload as string) ?? "Failed to update profile");
    }
  };

  return (
    <>
      <Typography as="h1" variant="subheading">
        Profile
      </Typography>

      <Form {...form}>
        <form
          onSubmit={form.handleSubmit(onSubmit)}
          className="flex flex-col gap-8"
        >
          <div className="rounded-xl flex flex-col gap-2 bg-white p-6 pb-12 border-border border-[3px] shadow-cartoon-lg">
            <div className="flex flex-col gap-1">
              <Typography variant={"label"}>Email</Typography>
              <Typography variant={"body"} className="text-ink-soft">
                {player.email}
              </Typography>
            </div>
            <FormField
              control={form.control}
              name="username"
              render={({ field }) => (
                <FormItem>
                  <div className="flex gap-2 items-center">
                    <FormLabel>Username</FormLabel>
                    <FormMessage />
                  </div>
                  <FormControl>
                    <CartoonInput placeholder="hero_name" {...field} />
                  </FormControl>
                </FormItem>
              )}
            />

            <FormField
              control={form.control}
              name="display_name"
              render={({ field }) => (
                <FormItem>
                  <div className="flex gap-2 items-center">
                    <FormLabel>Display Name</FormLabel>
                    <FormMessage />
                  </div>
                  <FormControl>
                    <CartoonInput
                      placeholder="Optional display name"
                      {...field}
                    />
                  </FormControl>
                </FormItem>
              )}
            />

            <div className="grid grid-cols-2 gap-4">
              <FormField
                control={form.control}
                name="age"
                render={({ field }) => (
                  <FormItem>
                    <div className="flex gap-2 items-center">
                      <FormLabel>Age</FormLabel>
                      <FormMessage />
                    </div>
                    <FormControl>
                      <CartoonInput
                        type="number"
                        min={1}
                        placeholder="10"
                        {...field}
                      />
                    </FormControl>
                  </FormItem>
                )}
              />

              <FormField
                control={form.control}
                name="grade"
                render={({ field }) => (
                  <FormItem>
                    <div className="flex gap-2 items-center">
                      <FormLabel>Grade</FormLabel>
                      <FormMessage />
                    </div>
                    <FormControl>
                      <CartoonSelect
                        options={GRADES}
                        value={field.value}
                        onValueChange={field.onChange}
                        placeholder="Select grade"
                      />
                    </FormControl>
                  </FormItem>
                )}
              />
            </div>

            <FormField
              control={form.control}
              name="guardian_email"
              render={({ field }) => (
                <FormItem>
                  <div className="flex gap-2 items-center">
                    <FormLabel>Guardian Email</FormLabel>
                    <FormMessage />
                  </div>
                  <FormControl>
                    <CartoonInput
                      type="email"
                      placeholder="guardian@example.com"
                      {...field}
                    />
                  </FormControl>
                </FormItem>
              )}
            />
          </div>

          {form.formState.isDirty && (
            <CartoonButton type="submit" className="w-full" disabled={loading}>
              <Save className="w-5 h-5" />
              {loading ? "Saving..." : "Save Changes"}
            </CartoonButton>
          )}
        </form>
      </Form>
    </>
  );
}

export function StatisticsTab() {
  const player = useSelector(selectCurrentPlayer)!;
  const accuracy =
    player.total_questions_answered > 0
      ? Math.round(
          (player.total_correct / player.total_questions_answered) * 100,
        )
      : 0;

  return (
    <>
      <Typography as="h1" variant="subheading">
        Statistics
      </Typography>

      <div className="rounded-xl flex flex-col gap-4">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
          <StatCard label="ELO" value={player.current_elo} />
          <StatCard
            label="Questions Answered"
            value={player.total_questions_answered}
          />
          <StatCard label="Accuracy" value={`${accuracy}%`} />
          <StatCard label="Correct" value={player.total_correct} />
          <StatCard label="Incorrect" value={player.total_incorrect} />
          <StatCard label="Longest Streak" value={player.longest_streak} />
        </div>
      </div>
    </>
  );
}

export function ProfilePageContainer() {
  const currentPlayer = useSelector(selectCurrentPlayer);
  if (!currentPlayer) return null;
  return <SettingsLayout />;
}
