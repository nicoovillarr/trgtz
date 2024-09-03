import { useEffect, useRef, useState } from "react"

function DemoItem({
    title,
    description,
    imageSource,
    jeje, isActive = false
  }: {
    title: string,
    description: string,
    imageSource: string,
    jeje: () => void,
    isActive?: boolean
  }) {
  return <li
      tabIndex={1}
      className={`w-full shrink-0 xs:w-4/5 sm:w-2/5 md:w-1/3 h-[500px] flex flex-col p-4 text-center cursor-pointer overflow-hidden transition-all ${isActive ? '' : 'opacity-50 scale-90'}`}
      onClick={jeje}>
    <h3 className="text-xl font-medium mb-2">{title}</h3>
    <p className="text-sm mb-2">{description}</p>
    {/* <div className="w-full flex-1 bg-primary rounded-md shadow-xl"></div> */}
    <img src={imageSource} alt="demo" className="w-full flex-1 rounded-md" />
  </li>
}

function DemoDots ({ activeIndex }: { activeIndex: number }) {
  return <div className="flex gap-x-2 justify-center">
    {Array(3).fill(0).map((_, index) => <div key={index} className={`h-2 bg-primary rounded-full transition-all ${activeIndex === index ? 'w-8' : 'w-2 opacity-75'}`}></div>)}
  </div>
}

export default function Demo() {
  const [activeIndex, setActiveIndex] = useState(0)

  const items = [
    {
      title: "Join the trgtz community",
      description: "Sign up for an account and start your journey to a better you. Connect with friends and family to share your progress and stay motivated.",
      imageSource: "/public/images/demo/login.webp"
    },
    {
        title: "Set your goals",
        description: "Easily create and manage your goals. Break them into actionable steps and set deadlines to keep yourself on track.",
      imageSource: "/public/images/demo/home.webp"
      },
    {
      title: "Share your progress",
      description: "Keep your friends updated on your journey. Share milestones, challenges and victories to stay motivated and accountable",
      imageSource: "/public/images/demo/goal.webp"
    }
  ]

  const scrollRef = useRef(null);

  useEffect(() => {
    const scrollElement = (scrollRef.current! as HTMLElement);
    let intervalId: any;
    let currentIndex = 0;
    const itemWidth = (scrollElement.firstChild as HTMLElement).clientWidth;
    const viewportWidth = scrollElement.clientWidth;
    const flexWidth = itemWidth * scrollElement.childElementCount;

    const startAutoScroll = () => {
      intervalId = setInterval(() => {
        if (currentIndex >= scrollElement.childElementCount) {
          currentIndex = 0;
        }

        const itemCenter = (currentIndex * itemWidth) + (itemWidth / 2);
        const scrollLeft = itemCenter - (viewportWidth / 2);

        scrollElement.scrollTo({
          left: Math.max(0, Math.min(scrollLeft, flexWidth - viewportWidth)),
          behavior: 'smooth',
        });

        setActiveIndex(currentIndex++);
      }, 5000);
    };

    startAutoScroll();

    return () => clearInterval(intervalId);
  }, []);


  return <section id="demo" className="w-full p-8 mx-auto overflow-scroll md:w-4/5 lg:w-2/3">
    <h1 className="text-4xl font-josefin-sans text-center mb-4 font-bold">
      See trgtz in action
    </h1>
    <ul 
      ref={scrollRef}
      className="flex mb-4 overflow-hidden">
      {items.map((item, index) => <DemoItem key={index} {...item} isActive={activeIndex === index} jeje={() => setActiveIndex(index)} />)}
    </ul>
  
    <DemoDots activeIndex={activeIndex} />
  </section>
}
