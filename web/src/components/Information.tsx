import { useState } from "react";
import { Icon } from "@iconify/react";

function Features() {
  return (
    <div className="flex flex-col gap-y-8 p-8 w-full mx-auto sm:w-2/3 md:w-3/5 xl:w-1/3">
      <article className="bg-white shadow-lg rounded-md p-4 flex">
        <div
          className="bg-primary w-12 h-12 rounded-md flex justify-center items-center text-white text-xs font-bold shadow-sm mr-4 shrink-0"
        >
          <Icon className="text-2xl" icon="bi:check-all" />
        </div>
        <aside>
          <h2 className="font-medium">Set goals</h2>
          <p className="text-gray-500 text-sm">
            Easily set and manage your yearly goals within the app.
          </p>
        </aside>
      </article>
      <article className="bg-white shadow-lg rounded-md p-4 flex">
        <div
          className="bg-primary w-12 h-12 rounded-md flex justify-center items-center text-white text-xs font-bold shadow-sm mr-4 shrink-0"
        >
          <Icon className="text-2xl" icon="bi:people" />
        </div>
        <aside>
          <h2 className="font-medium">Share with friends</h2>
          <p className="text-gray-500 text-sm">
            Connect with friends and share your goals for mutual support.
          </p>
        </aside>
      </article>
      <article className="bg-white shadow-lg rounded-md p-4 flex">
        <div
          className="bg-primary w-12 h-12 rounded-md flex justify-center items-center text-white text-xs font-bold shadow-sm mr-4 shrink-0"
        >
          <Icon className="text-2xl" icon="bi:trophy" />
        </div>
        <aside>
          <h2 className="font-medium">Celebrate achievements</h2>
          <p className="text-gray-500 text-sm">
            Celebrate every milestone and achievement with your network.
          </p>
        </aside>
      </article>
      <article className="bg-white shadow-lg rounded-md p-4 flex">
        <div
          className="bg-primary w-12 h-12 rounded-md flex justify-center items-center text-white text-xs font-bold shadow-sm mr-4 shrink-0"
        >
          <Icon className="text-2xl" icon="bi:phone" />
        </div>
        <aside>
          <h2 className="font-medium">Mobile app</h2>
          <p className="text-gray-500 text-sm">
            access your goals-on-the-go with our mobile app.
          </p>
        </aside>
      </article>
    </div>
  )
}

function How() {
  const items = [
    {
      title: "Built with Flutter",
      description: "Trgtz is developed using Flutter, Google's powerful UI toolkit for crafting natively compiled applications for mobile, web, and desktop from a single codebase. This ensures a seamless and consistent experience across all platforms, making your goals accessible wherever you go."
    },
    {
      title: "Powered by ExpressJS",
      description: "The backend of Trgtz is built using ExpressJS, a fast and flexible Node.js web application framework. This provides a robust API to handle all your requests efficiently, from adding new goals to updating your progress. The flexibility of ExpressJS allows us to quickly adapt and scale as the app grows, ensuring a responsive and reliable experience."
    },
    {
      title: "Database Built on MongoDB",
      description: "Trgtz relies on MongoDB, a powerful NoSQL database, to store all your goals, progress, and user data. MongoDB allows for flexible and scalable data management, ensuring that your information is stored securely and efficiently. This setup enables fast queries and real-time data access, making your experience smooth and seamless."
    },
    {
      title: "Real-Time Updates with WebSockets",
      description: "Stay up-to-date with real-time changes thanks to WebSocket technology. When you or your friends update a goal or achieve a milestone, the changes are reflected instantly across all devices. This ensures that everyone stays in sync and keeps the motivation flowing without any delay."
    },
    {
      title: "Secure and Private",
      description: "Your data security is crucial. Trgtz implements strong security measures, including data encryption and authentication protocols, to protect your personal information. ExpressJS allows us to integrate security layers that safeguard your interactions and data against potential threats, so you can focus on reaching your goals with confidence."
    },
    {
      title: "Continuous Development and Improvement",
      description: "We are committed to continuous improvement. By following agile development practices and utilizing modern tools like GitHub Actions for Continuous Integration and Delivery (CI/CD), Trgtz is constantly evolving. Expect regular updates, new features, and fast bug fixes, all driven by user feedback."
    }
  ]
  return (
    <ul className="mx-auto p-8 w-full sm:w-2/3 md:w-3/5 xl:w-1/3">
      {items.map((item, index) => (
        <li
          key={index}
          className="relative pb-8">
          {index !== items.length - 1 && <div className="absolute w-0.5 bottom-2 top-10 left-[0.95rem] bg-gray-400 rounded-md"></div>}
          <div className="w-8 h-8 bg-primary rounded-full flex justify-center items-center text-white text-xs float-left">{index + 1}</div>
          <div className="ml-10 pt-0.5">
            <h2 className="text-lg font-medium">{item['title']}</h2>
            <p className="text-gray-600">
              {item['description']}
            </p>
          </div>
        </li>
      ))}
    </ul>
  )
}

function FAQ() {
  const [activeIndex, setActiveIndex] = useState(0)

  const items = [
    {
      title: "What is Trgtz?",
      description: "Trgtz is a goal-setting and tracking app that helps you set, manage, and achieve your goals. With Trgtz, you can create personalized goals, break them down into actionable steps, and track your progress over time. You can also connect with friends to share your goals, celebrate achievements, and stay motivated together."
    },
    {
      title: "How do I create a new goal?",
      description: "To create a new goal, simply log in to your account and click on the 'Add Goal' button. You will be prompted to enter the details of your goal, including the title, description, deadline, and milestones. Once you have filled in all the required information, click 'Save' to create your new goal."
    },
    {
      title: "Can I share my goals with friends?",
      description: "Absolutely! You can share any of your goals with your friends by inviting them through the app. They can see your progress, cheer you on, and even join you in celebrating your achievements."
    },
    {
      title: "How does the real-time feature work?",
      description: "Thanks to our implementation of WebSockets, any updates you make to your goals, progress, or milestones are instantly reflected across all your connected devices and shared with your friends in real-time. No refresh needed!"
    },
    {
      title: "What if I need to change or delete a goal?",
      description: "No problem! You can easily edit or delete any goal from your goal list. Simply tap on the goal, make the necessary changes, or select the delete option if you no longer wish to track it."
    },
    {
      title: "Will Trgtz always be free?",
      description: "Yes, Trgtz will always have a free version available. The main pourpose of the app is to show people what we can do. We don't have any plans to charge for the app, but we may introduce premium features in the future."
    }
  ]

  return (
    <ul className="p-8 w-full mx-auto sm:w-4/5 md:w-3/5 xl:w-2/5">
      {items.map((item, index) => (
        <li
          key={index}
          className="relative bg-white rounded-lg shadow-lg mb-8 p-8">
          <div className="flex items-center gap-x-4">
            <div
              key={index}
              className={`w-12 h-12 shrink-0 bg-gray-50 rounded-md border-2 flex justify-center items-center cursor-pointer ${activeIndex === index ? 'text-primary border-prmary' : 'text-gray-400 border-gray-200'}`}
              onClick={() => setActiveIndex(index)}>
              {activeIndex === index ? <Icon icon="bi:chevron-down" /> : <Icon icon="bi:chevron-right" />}
            </div>
            <h2 className="text-lg font-medium">{item['title']}</h2>
          </div>
          <p className={`mt-4 text-gray-600 ${activeIndex === index ? 'blobk' : 'hidden'}`}>
            {item['description']}
          </p>
        </li>
      ))}
    </ul>
  )
}

export default function Information() {
  const [activeIndex, setActiveIndex] = useState(0)

  const styles = {
    active: "border-b-2 border-primary",
    inactive: "text-gray-500 cursor-pointer transition-all hover:text-primary"
  }

  return (
    <section id="info" className="w-screen bg-gray-100">
      <div className="w-screen bg-white py-4 shadow-md">
        <ul className="flex items-center gap-x-4 justify-center">
          <li className={`transition-all ${styles[activeIndex == 0 ? 'active' : 'inactive']}`}>
            <button onClick={() => setActiveIndex(0)}>
              Features
            </button>
          </li>
          <li className={`transition-all ${styles[activeIndex == 1 ? 'active' : 'inactive']}`}>
            <button onClick={() => setActiveIndex(1)}>
              How It Works
            </button>
          </li>
          <li className={`transition-all ${styles[activeIndex == 2 ? 'active' : 'inactive']}`}>
            <button onClick={() => setActiveIndex(2)}>
              FAQ
            </button>
          </li>
        </ul>
      </div>
  
      {activeIndex === 0 && <Features />}
      {activeIndex === 1 && <How />}
      {activeIndex === 2 && <FAQ />}
    </section>
  );
}
