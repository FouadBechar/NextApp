"use client";
import { useEffect, useRef, useState } from "react";
import FocusLock from "react-focus-lock";
import SafeImage from "./ui/SafeImage";

const videoUrl =
  "https://res.cloudinary.com/dgi9vyjff/video/upload/v1729979577/WWF.mp4";
const posterImage = "/assets/d1.webp";

export default function VideoShow() {
  const [isOpen, setIsOpen] = useState(false);
  const videoRef = useRef<HTMLVideoElement | null>(null);
  const closeButtonRef = useRef<HTMLButtonElement | null>(null);

  useEffect(() => {
    const videoEl = videoRef.current;
    if (!videoEl) return;

    if (isOpen) {
      videoEl.src = videoUrl;
      videoEl.muted = false;
      const playPromise = videoEl.play();
      if (playPromise && typeof playPromise.catch === "function") {
        playPromise.catch((err: unknown) => {
          console.debug("Videoshow play() promise rejected", err);
        });
      }
    } else {
      try {
        videoEl.pause();
        videoEl.currentTime = 0;
        videoEl.removeAttribute("src");
        videoEl.load();
      } catch (err) {
        console.debug("Videoshow cleanup error", err);
      }
    }
  }, [isOpen]);

  useEffect(() => {
    if (!isOpen) return undefined;

    function handleKeyDown(event: KeyboardEvent) {
      if (event.key === "Escape") {
        setIsOpen(false);
      }
    }

    document.addEventListener("keydown", handleKeyDown);
    return () => {
      document.removeEventListener("keydown", handleKeyDown);
    };
  }, [isOpen]);

  useEffect(() => {
    if (!isOpen) return undefined;

    closeButtonRef.current?.focus();
    const previousOverflow = document.body.style.overflow;
    document.body.style.overflow = "hidden";

    return () => {
      document.body.style.overflow = previousOverflow;
    };
  }, [isOpen]);

  return (
    <section className="video-card">
      <div className="video-card__preview">
        <SafeImage
          className="video-card__preview-image"
          src={posterImage}
          width={640}
          height={360}
          alt="WWF video preview"
        />
        <button
          type="button"
          className="video-card__trigger"
          onClick={() => setIsOpen(true)}
          aria-label="Open WWF video preview"
        />
        <div className="video-card__play-overlay">
          <span className="video-card__play-icon" aria-hidden="true">
            ▶
          </span>
        </div>
        <div className="video-card__info video-card__info--overlay">
          {/* <div className="video-card__eyebrow"> Featured video </div> */}
          <h2>WWF Conservation Film</h2>
          <p className="video-card__description video-card__description--desktop">
            Watch a short documentary from WWF that highlights conservation work
            protecting endangered wildlife and habitats.
          </p>
          <p className="video-card__description video-card__description--mobile">
            A short look at wildlife and habitat protection.
          </p>
          <div className="video-card__actions">
            <button
              type="button"
              className="video-button video-button--primary"
              onClick={() => setIsOpen(true)}
            >
              Play video
            </button>
            <a
              href="https://www.worldwildlife.org/"
              target="_blank"
              rel="noopener noreferrer"
              aria-label="Learn more about the World Wildlife Fund"
              className="video-button video-button--secondary video-button--link-mobile"
            >
              Learn more
            </a>
          </div>
        </div>
      </div>

      {isOpen && (
        <div
          className="video-modal"
          role="dialog"
          aria-modal="true"
          aria-labelledby="video-modal-title"
        >
          <div
            className="video-modal__backdrop"
            onClick={() => setIsOpen(false)}
          />
          <FocusLock returnFocus autoFocus>
            <div className="video-modal__content">
              <h2 id="video-modal-title" className="sr-only">
                WWF video player
              </h2>
              <button
                ref={closeButtonRef}
                type="button"
                className="video-modal__close"
                onClick={() => setIsOpen(false)}
                aria-label="Close video"
              >
                ×
              </button>
              <video
                ref={videoRef}
                className="video-modal__player"
                controls
                playsInline
                poster={posterImage}
              />
            </div>
          </FocusLock>
        </div>
      )}
    </section>
  );
}
