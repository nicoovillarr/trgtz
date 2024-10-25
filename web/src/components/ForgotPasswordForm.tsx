import UserInfo from "./UserInfo";
import Input from "./Input";
import Button from "./Button";
import { useEffect, useRef, useState } from "react";

export default function ForgotPasswordForm() {
  const [token, setToken] = useState("");

  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [invalidToken, setInvalidToken] = useState(false);
  const [success, setSuccess] = useState(false);

  const [userName, setUserName] = useState("");
  const [userImage, setUserImage] = useState("");

  const [buttonText, setButtonText] = useState("Reset password");
  const [buttonDisabled, setButtonDisabled] = useState(false);

  useEffect(() => {
    const queryParams = new URLSearchParams(window.location.search);
    const token = queryParams.get("token");
    if (!token) {
      return;
    }

    setToken(token!);

    const fetchData = async () => {
      try {
        const endpoint = `${
          import.meta.env.PUBLIC_API_URL
        }/tokens/validate-token/${token}?type=password_reset`;
        const response = await fetch(endpoint);

        if (!response.ok) {
          setInvalidToken(true);
          return;
        }

        const data = await response.json();
        setUserName(data.firstName);
        setUserImage(data.image);
      } catch (error) {
        console.error("Error fetching user data: ", error);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  const formRefKey = useRef<HTMLFormElement>(null);

  const handleSubmit = async () => {
    if (loading || invalidToken) return;

    const form = formRefKey.current;
    if (form) {
      const newPassInput = form.elements.namedItem(
        "newPass"
      ) as HTMLInputElement;

      const repeatPassInput = form.elements.namedItem(
        "repeat"
      ) as HTMLInputElement;

      if (!newPassInput || !repeatPassInput) {
        setError("Error: Inputs not found");
        return;
      }

      if (newPassInput.value !== repeatPassInput.value) {
        setError("Passwords do not match");
        return;
      }

      setLoading(true);
      setButtonDisabled(true);
      setButtonText("Loading...");
      setError("");

      try {
        const response = await fetch(
          "http://localhost:3000/auth/reset-password",
          {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
            },
            body: JSON.stringify({
              token,
              password: newPassInput.value,
            }),
          }
        );

        if (response.ok) {
          setSuccess(true);
        } else {
          const data = await response.json();
          setError(data.message);
        }
      } catch (e) {
        console.error(e);
      } finally {
        setLoading(false);
        setButtonDisabled(false);
        setButtonText("Reset password");
      }
    }
  };

  if (invalidToken) {
    return (
      <section className="w-3/4 md:w-1/2 lg:w-1/3 max-w-[640px] mx-auto">
        <article className="flex flex-col items-center bg-white rounded-md shadow-md p-8">
          <h2 className="font-bold">Invalid token</h2>
          <p className="text-gray-500 text-sm text-center">
            The token provided is invalid or has expired.
          </p>
        </article>
      </section>
    );
  }

  if (success) {
    return (
      <section className="w-3/4 md:w-1/2 lg:w-1/3 max-w-[640px] mx-auto">
        <article className="flex flex-col items-center bg-white rounded-md shadow-md p-8">
          <h2 className="font-bold">Password reset</h2>
          <p className="text-gray-500 text-sm text-center">
            Your password has been reset successfully.
          </p>
        </article>
      </section>
    );
  }

  return (
    <form
      ref={formRefKey}
      className="w-3/4 md:w-1/2 lg:w-1/3 max-w-[640px] mx-auto"
    >
      <article className="flex flex-col items-center bg-white rounded-md shadow-md p-8 mb-8">
        <UserInfo firstName={userName} image={userImage} />
      </article>
      <article className="flex flex-col bg-white rounded-md shadow-md p-8">
        <h2 className="font-bold">Forgot password</h2>
        <p className="text-gray-500 text-sm mb-4">
          Fill the following form to reset the password of your Trgtz user.
        </p>
        <Input
          id="newPass"
          className="mb-4"
          label="New password"
          type="password"
        />
        <Input
          id="repeat"
          className="mb-4"
          label="Repeat password"
          type="password"
        />
        <div className="flex flex-col items-end gap-y-2">
          <Button onClick={handleSubmit} disabled={buttonDisabled}>
            {buttonText}
          </Button>
          {error && <p className="text-red-500 text-sm font-medium">{error}</p>}
        </div>
      </article>
    </form>
  );
}
