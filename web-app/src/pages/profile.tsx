import { z } from "zod";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { Save } from "lucide-react";
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

const profileFormSchema = z.object({
  username: z.string().min(3, "At least 3 characters").max(32, "Too long").optional(),
  display_name: z.string().max(64, "Too long").optional(),
  age: z
    .string()
    .regex(/^\d+$/, "Must be a number")
    .refine((v) => Number(v) >= 1, "Invalid age")
    .optional()
    .or(z.literal("")),
  grade: z.string().optional(),
  guardian_email: z.string().email("Enter a valid email").optional().or(z.literal("")),
});

type ProfileFormValues = z.infer<typeof profileFormSchema>;

function ProfilePage() {
  const dispatch = useDispatch();
  const currentPlayer = useSelector(selectCurrentPlayer)!;
  const loading = useSelector(selectPlayerLoading);

  const form = useForm<ProfileFormValues>({
    resolver: zodResolver(profileFormSchema),
    defaultValues: {
      username: currentPlayer.username,
      display_name: currentPlayer.display_name ?? "",
      age: currentPlayer.age?.toString() ?? "",
      grade: currentPlayer.grade?.toString() ?? "",
      guardian_email: currentPlayer.guardian_email ?? "",
    },
  });

  const onSubmit = async (values: ProfileFormValues) => {
    const body: RequestUpdatePlayer = {};
    if (values.username) body.username = values.username;
    if (values.display_name) body.display_name = values.display_name;
    if (values.age) body.age = parseInt(values.age, 10);
    if (values.grade) body.grade = parseInt(values.grade, 10);
    if (values.guardian_email) body.guardian_email = values.guardian_email;

    const result = await dispatch(patchPlayer({ id: currentPlayer.id, body }));
    if (patchPlayer.fulfilled.match(result)) {
      form.reset(values);
    } else {
      toastError((result.payload as string) ?? "Failed to update profile");
    }
  };

  return (
    <PageLayout title="Profile">
      <div className="max-w-xl mx-auto">
        <Typography as="h1" variant="subheading" className="mb-6">
          Your Profile
        </Typography>

        <Form {...form}>
          <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-5">
            <div className="bg-white border-[3px] border-ink rounded-cartoon-lg p-6 space-y-5">
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
                      <CartoonInput placeholder="Optional display name" {...field} />
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
      </div>
    </PageLayout>
  );
}

export function ProfilePageContainer() {
  const currentPlayer = useSelector(selectCurrentPlayer);
  if (!currentPlayer) return null;
  return <ProfilePage />;
}
