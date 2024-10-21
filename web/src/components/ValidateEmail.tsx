import { useEffect, useState } from "react";
import Card from "./Card";
import Shimmer from "./Shimmer";

export default function ValidateEmail() {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);

  useEffect(() => {
    const queryParams = new URLSearchParams(window.location.search);
    const token = queryParams.get("token");
    if (!token) {
      setError(true);
      return;
    }

    const fetchData = async () => {
      try {
        const endpoint = `${
          import.meta.env.PUBLIC_API_URL
        }/users/validate?token=${token}`;
        const response = await fetch(endpoint, { method: "POST" });

        if (!response.ok) {
          setError(true);
          return;
        }
      } catch (error) {
        console.error("Error validating email: ", error);
        setError(true);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  return (
    <section className="w-3/4 md:w-1/2 lg:w-1/3 max-w-[640px] mx-auto">
      <Card>
        {loading ? (
          <p>Loading...</p>
        ) : error ? (
          <p className="text-red-600 font-medium">Invalid token</p>
        ) : (
          <p className="text-green-500">Email validated</p>
        )}
      </Card>
    </section>
  );
}
