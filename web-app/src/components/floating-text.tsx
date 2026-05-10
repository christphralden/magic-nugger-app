import { motion } from "motion/react";

export function FloatingText({
  text,
  offset = 0,
  duration = 3.6,
}: {
  text: string;
  offset?: number;
  duration?: number;
}) {
  return (
    <>
      {text.split("").map((char, i) => (
        <motion.span
          key={i}
          className="inline-block"
          animate={{ y: [0, -8, 0] }}
          transition={{
            duration: duration,
            repeat: Infinity,
            ease: "easeInOut",
            delay: (offset + i) * 0.065,
          }}
        >
          {char === " " ? " " : char}
        </motion.span>
      ))}
    </>
  );
}
