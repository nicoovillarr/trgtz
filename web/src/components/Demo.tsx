import { useEffect, useRef, useState } from "react";

function DemoItem({
  title,
  description,
  imageSource,
  click,
  isActive = false,
}: {
  title: string;
  description: string;
  imageSource: string;
  click: () => void;
  isActive?: boolean;
}) {
  return (
    <li
      tabIndex={1}
      className={`w-full shrink-0 xs:w-4/5 sm:w-2/5 md:w-1/3 h-[500px] flex flex-col p-4 text-center cursor-pointer overflow-hidden transition-all ${
        isActive ? "" : "opacity-50 scale-90"
      }`}
      onClick={click}
    >
      <h3 className="text-xl font-medium mb-2">{title}</h3>
      <p className="text-sm mb-2">{description}</p>
      <img
        src={imageSource}
        alt="demo"
        className="w-full  object-cover flex-1 rounded-md"
      />
    </li>
  );
}

function DemoDots({
  activeIndex,
  click,
}: {
  activeIndex: number;
  click: (index: number) => void;
}) {
  return (
    <div className="flex gap-x-2 justify-center">
      {Array(3)
        .fill(0)
        .map((_, index) => (
          <div
            key={index}
            className={`h-2 bg-primary rounded-full transition-all ${
              activeIndex === index ? "w-8" : "w-2 opacity-75"
            }`}
            onClick={() => click(index)}
          ></div>
        ))}
    </div>
  );
}

export default function Demo() {
  const [activeIndex, setActiveIndex] = useState(1);
  const [intervalId, setIntervalId] = useState(null);

  const items = [
    {
      title: "Join the trgtz community",
      description:
        "Sign up for an account and start your journey to a better you. Connect with friends and family to share your progress and stay motivated.",
      imageSource: "/images/demo/login.webp",
    },
    {
      title: "Set your goals",
      description:
        "Easily create and manage your goals. Break them into actionable steps and set deadlines to keep yourself on track.",
      imageSource: "/images/demo/home.webp",
    },
    {
      title: "Share your progress",
      description:
        "Keep your friends updated on your journey. Share milestones, challenges and victories to stay motivated and accountable",
      imageSource: "/images/demo/goal.webp",
    },
  ];

  const scrollRef = useRef(null);

  const startAutoScroll = () => {
    const scrollElement = scrollRef.current! as HTMLElement;
    setIntervalId((prev) => {
      if (prev) clearInterval(prev);

      return setInterval(() => {
        setActiveIndex((prevIndex) => {
          const newIndex =
            prevIndex >= scrollElement.childElementCount - 1
              ? 0
              : prevIndex + 1;
          scrollToItem(newIndex);
          return newIndex;
        });
      }, 5000);
    });
  };

  const scrollToItem = (newIndex: number) => {
    const scrollElement = scrollRef.current! as HTMLElement;
    const itemWidth = (scrollElement.firstChild as HTMLElement).clientWidth;
    const viewportWidth = scrollElement.clientWidth;
    const itemCenter = newIndex * itemWidth + itemWidth / 2;
    const scrollLeft = itemCenter - viewportWidth / 2;
    const flexWidth = itemWidth * scrollElement.childElementCount;

    scrollElement.scrollTo({
      left: Math.max(0, Math.min(scrollLeft, flexWidth - viewportWidth)),
      behavior: "smooth",
    });
  };

  const onCardClick = (index: number) => {
    if (index === activeIndex) return;
    scrollToItem(index);
    setActiveIndex(index);
    startAutoScroll();
  };

  useEffect(() => {
    scrollToItem(activeIndex);
    startAutoScroll();
    return () => clearInterval(intervalId);
  }, []);

  return (
    <section
      id="demo"
      className="w-full p-8 mx-auto overflow-hidden md:w-4/5 lg:w-2/3 lg:max-w-4xl"
    >
      <h1 className="text-4xl font-josefin-sans text-center mb-4 font-bold">
        See trgtz in action
      </h1>
      <ul ref={scrollRef} className="flex mb-4 overflow-hidden">
        {items.map((item, index) => (
          <DemoItem
            key={index}
            {...item}
            isActive={activeIndex === index}
            click={() => onCardClick(index)}
          />
        ))}
      </ul>

      <DemoDots
        activeIndex={activeIndex}
        click={(index) => onCardClick(index)}
      />
    </section>
  );
}
