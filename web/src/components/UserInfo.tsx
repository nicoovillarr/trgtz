import Shimmer from "./Shimmer";

export default function UserInfo({
  firstName,
  image,
}: {
  firstName: string;
  image: string;
}) {
  if (firstName) {
    return (
      <>
        {image && (
          <img
            className="w-20 h-20 rounded-full mb-4"
            src={image}
            alt={firstName}
          />
        )}
        <h2 className="font-medium">{firstName}</h2>
      </>
    );
  } else {
    return (
      <>
        <Shimmer height={100} width={100} rounded="full" className="mb-4" />
        <Shimmer height={24} width={100} />
      </>
    );
  }
}
