import React from 'react';
import { Link } from 'react-router-dom';
import { FiHome, FiArrowLeft, FiAlertTriangle } from 'react-icons/fi';

function NotFound404() {
    return (
        <div className="min-h-screen flex items-center justify-center px-4">
            <div className="max-w-lg w-full text-center">
                {/* Icon */}
                <div className="mb-8">
                    <div className="inline-flex items-center justify-center w-24 h-24 bg-white rounded-full shadow-lg">
                        <FiAlertTriangle className="text-yellow-500 text-5xl" />
                    </div>
                </div>

                {/* Title */}
                <h1 className="text-9xl font-bold text-gray-800 mb-2">404</h1>

                {/* Subtitle */}
                <h2 className="text-2xl font-semibold text-gray-700 mb-6">Page Not Found</h2>

                {/* Description */}
                <p className="text-gray-600 mb-8 text-lg">
                    Oops! The page you're looking for seems to have wandered off into the digital void.
                </p>

                {/* Action Buttons */}
                <div className="flex flex-col sm:flex-row gap-4 justify-center">
                    <Link
                        to="/"
                        className="inline-flex items-center justify-center px-6 py-3 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 transition-colors shadow-md"
                    >
                        <FiHome className="mr-2" />
                        Go Home
                    </Link>

                    <button
                        onClick={() => window.history.back()}
                        className="inline-flex items-center justify-center px-6 py-3 bg-white text-gray-800 font-medium rounded-lg border border-gray-300 hover:bg-gray-50 transition-colors shadow-md"
                    >
                        <FiArrowLeft className="mr-2" />
                        Go Back
                    </button>
                </div>

                {/* Decorative Elements */}
                <div className="mt-12 text-gray-400">
                    <p className="text-sm">If you believe this is an error, please contact support.</p>
                </div>
            </div>
        </div>
    );
}

export default NotFound404;