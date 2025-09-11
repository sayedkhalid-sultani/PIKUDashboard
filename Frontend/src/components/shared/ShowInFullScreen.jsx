import { useState, useEffect, useRef } from 'react';
import { FiMaximize, FiMinimize, FiPrinter, FiDownload, FiX } from 'react-icons/fi';
import { useReactToPrint } from 'react-to-print';
import html2canvas from 'html2canvas';

function ShowInFullScreen({
    children,
    modalClassName = "w-full max-w-4xl py-10 px-5",
    previewClassName = "",
    contentClassName = "w-full h-full",
    containerClassName = "w-auto h-auto",
}) {
    const [open, setOpen] = useState(false);
    const [animating, setAnimating] = useState(false);
    const [showOpenAnim, setShowOpenAnim] = useState(false);
    const contentRef = useRef(null);

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

    // Print handler using react-to-print (new API)
    const handlePrint = useReactToPrint({
        contentRef,
        documentTitle: 'Dashboard Chart',
    });

    // Download as image handler
    const handleDownloadImage = async () => {
        const chartEl = contentRef.current;
        if (chartEl) {
            chartEl.classList.add('html2canvas-fix', 'p-0');
            try {
                const canvas = await html2canvas(chartEl, {
                    scale: 2,
                    // useCORS: true,
                    // backgroundColor: "#fff"
                });
                const image = canvas.toDataURL("image/png");
                const link = document.createElement('a');
                link.href = image;
                link.download = 'chart.png';
                link.click();
            } finally {
                chartEl.classList.remove('html2canvas-fix', 'p-0');
            }
        }
    };

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
                            // <-- Attach ref here!
                            className={`relative bg-white bg-opacity-90 border border-gray-200 shadow-xl rounded-lg ${modalClassName} transition-all duration-300 ${showOpenAnim ? "scale-100 opacity-100" : "scale-95 opacity-0"}`}
                        >
                            {/* Grouped action buttons */}
                            <div className="absolute top-2 right-2 flex gap-2 z-[100000]">
                                <div className="inline-flex rounded shadow bg-white bg-opacity-80 border border-gray-200 overflow-hidden">
                                    <button
                                        className="px-2 py-1 hover:bg-blue-50 transition flex items-center justify-center"
                                        onClick={handlePrint}
                                        title="Print"
                                        aria-label="Print modal content"
                                        disabled={!open}
                                    >
                                        <FiPrinter size={20} />
                                    </button>
                                    <button
                                        className="px-2 py-1 hover:bg-blue-50 transition flex items-center justify-center"
                                        onClick={handleDownloadImage}
                                        title="Download as image"
                                        aria-label="Download chart as image"
                                        disabled={!open}
                                    >
                                        <FiDownload size={20} />
                                    </button>
                                    <button
                                        className="px-2 py-1 hover:bg-red-50 transition flex items-center justify-center border-l border-gray-200"
                                        onClick={() => setOpen(false)}
                                        title="Close"
                                        aria-label="Close full screen"
                                    >
                                        <FiMinimize size={20} />
                                    </button>
                                </div>
                            </div>
                            <div className={`${contentClassName}`} ref={contentRef} >
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