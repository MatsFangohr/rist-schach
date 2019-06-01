/* eslint-disable max-len */
import React, {useEffect, useState} from "react";
// import PropTypes from "prop-types";
import styles from "./windows-controls.module.css";

// https://github.com/microsoft/vscode/tree/master/src/vs/workbench/browser/parts/titlebar/media
const Close = () => (
    <svg
        fill="none"
        height="11"
        viewBox="0 0 11 11"
        width="11"
        xmlns="http://www.w3.org/2000/svg"
    >
        <path
            d="M6.279 5.5L11 10.221l-.779.779L5.5 6.279.779 11 0 10.221 4.721 5.5 0 .779.779 0 5.5 4.721 10.221 0 11 .779 6.279 5.5z"
            fill="#000"
        />
    </svg>
);

const Maximize = () => (
    <svg
        fill="none"
        height="11"
        viewBox="0 0 11 11"
        width="11"
        xmlns="http://www.w3.org/2000/svg"
    >
        <path d="M11 0v11H0V0h11zM9.899 1.101H1.1V9.9H9.9V1.1z" fill="#000"/>
    </svg>
);

const Minimize = () => (
    <svg
        fill="none"
        height="11"
        viewBox="0 0 11 11"
        width="11"
        xmlns="http://www.w3.org/2000/svg"
    >
        <path d="M11 4.399V5.5H0V4.399h11z" fill="#000"/>
    </svg>
);

const Restore = () => (
    <svg
        fill="none"
        height="11"
        viewBox="0 0 11 11"
        width="11"
        xmlns="http://www.w3.org/2000/svg"
    >
        <path
            d="M11 8.798H8.798V11H0V2.202h2.202V0H11v8.798zm-3.298-5.5h-6.6v6.6h6.6v-6.6zM9.9 1.1H3.298v1.101h5.5v5.5h1.1v-6.6z"
            fill="#000"
        />
    </svg>
);

const appWindow = (window.require)
    ? window.require("electron").remote.getCurrentWindow()
    : false;

export default function Controls() {
    const [isMaximized, setIsMaximized] = useState(false);
    useEffect(
        function () {
            appWindow.on("maximize", () => setIsMaximized(true));
            appWindow.on("unmaximize", () => setIsMaximized(false));
            setIsMaximized(appWindow.isMaximized());
        },
        []
    );
    return (
        <div className={styles.container}>
            <button
                className={styles.winButton + " button-ghost"}
                onClick={() => appWindow.minimize()}
            >
                <Minimize />
            </button>
            {(isMaximized)
            ? (
                <button
                    className={styles.winButton + " button-ghost"}
                    onClick={() => appWindow.unmaximize()}
                >
                    <Restore />
                </button>
            ) : (
                <button
                    className={styles.winButton + " button-ghost"}
                    onClick={() => appWindow.maximize()}
                >
                    <Maximize />
                </button>
            )}
            <button
                className={styles.winButton + " button-ghost"}
                onClick={() => appWindow.close()}
            >
                <Close />
            </button>
        </div>
    );
}
Controls.propTypes = {
    // isFullScreen: PropTypes.bool.isRequired
};