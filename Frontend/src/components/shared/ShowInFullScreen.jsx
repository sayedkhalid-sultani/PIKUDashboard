import { useState, useEffect, useRef } from 'react';
import { FiMaximize, FiMinimize } from 'react-icons/fi';

function ShowInFullScreen({
    children,
    modalClassName = "w-full max-w-4xl py-10 px-2",
    previewClassName = "",
    contentClassName = "w-full h-full flex items-center justify-center",
    containerClassName = "w-auto h-auto",
}) {
    const [open, setOpen] = useState(false);
    const [animating, setAnimating] = useState(false);
    const [showOpenAnim, setShowOpenAnim] = useState(false);
    const modalRef = useRef();

    // Handle escape key to close modal
    useEffect(() => {
        const handleEscape = (e) => {
            if (e.keyCode === 27) setOpen(false);
        };

        if (open) {
            document.addEventListener('keydown', handleEscape);
            document.body.style.overflow = 'hidden';
        }

        return () => {
            document.removeEventListener('keydown', handleEscape);
            document.body.style.overflow = 'unset';
        };
    }, [open]);

    // Animation for modal open/close
    useEffect(() => {
        if (open) {
            setAnimating(true);
            setShowOpenAnim(false);
            // Wait for next tick to trigger transition
            setTimeout(() => setShowOpenAnim(true), 10);
        } else {
            // Delay unmount for animation
            if (animating) {
                setShowOpenAnim(false);
                const timeout = setTimeout(() => setAnimating(false), 250);
                return () => clearTimeout(timeout);
            }
        }
    }, [animating, open]);

    return (
        <div className={`relative ${containerClassName}`}>
            {/* Preview section */}
            <div className={`relative ${previewClassName}`}>
                {children}
                {/* Expand button */}
                {!open && (
                    <button
                        className="absolute top-2 right-2 z-10 p-1 rounded bg-white bg-opacity-70 hover:bg-opacity-100 transition-all shadow-md flex items-center justify-center"
                        title="Show in fullscreen"
                        onClick={() => setOpen(true)}
                        aria-label="Expand to full screen"
                        style={{ zIndex: 2000 }}
                    >
                        <FiMaximize size={20} />
                    </button>
                )}
            </div>

            {/* Full-screen modal with transition */}
            {(open || animating) && (
                <>
                    <div
                        className={`fixed inset-0 z-[2001] flex items-center justify-center bg-opacity-50 backdrop-blur-sm transition-opacity duration-300 ${showOpenAnim ? "opacity-100" : "opacity-0"}`}
                        tabIndex={-1}
                        aria-modal="true"
                        role="dialog"
                        onClick={e => e.stopPropagation() && setOpen(false)}
                    >
                        <div
                            ref={modalRef}
                            className={`relative bg-white bg-opacity-90 border border-gray-200 shadow-xl rounded-lg ${modalClassName} transition-all duration-300 ${showOpenAnim ? "scale-100 opacity-100" : "scale-95 opacity-0"}`}
                        >
                            <button
                                className="absolute top-2 right-2 p-1 rounded bg-white bg-opacity-70 hover:bg-opacity-100 transition-all shadow-md flex items-center justify-center"
                                onClick={() => setOpen(false)}
                                title="Close"
                                aria-label="Close full screen"
                                style={{ zIndex: 100000 }}
                            >
                                <FiMinimize size={20} />
                            </button>
                            <div className={contentClassName}>
                                {children}
                            </div>
                            <div className="mt-4 text-xs text-gray-400 text-center">
                                Press ESC or click outside to close
                            </div>
                        </div>
                    </div>
                </>
            )}
        </div>
    );
}

export default ShowInFullScreen;