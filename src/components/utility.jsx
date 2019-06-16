import Icons from "./icons";
import PropTypes from "prop-types";
import React from "react";
import classNames from "classnames";
import {omit} from "ramda";
import styles from "./utility.module.css";

export function Panel({children, style}) {
    return (
        <div className={styles.panel} style={{...style}}>
            {children}
        </div>
    );
}
Panel.propTypes = {
    children: PropTypes.node.isRequired,
    style: PropTypes.object
};

export function PanelContainer(props) {
    return (
        <div {...props} className={classNames(styles.panels, props.className)}>
            {props.children}
        </div>
    );
}
PanelContainer.propTypes = {
    children: PropTypes.node.isRequired,
    className: PropTypes.string
};

export function DateFormat(props) {
    const dateFormat = new Intl.DateTimeFormat(
        "en-US",
        {
            day: "2-digit",
            month: "short",
            year: "numeric"
        }
    );
    const cleanProps = omit(["date"], props);
    return (
        <time dateTime={props.date.toISOString()} {...cleanProps}>
            {dateFormat.format(props.date)}
        </time>
    );
}
DateFormat.propTypes = {
    date: PropTypes.instanceOf(Date)
};

export function Notification(props) {
    const [icon, className] = (function () {
        if (props.success) {
            return [<Icons.Check />, "notification__success"];
        } else if (props.warning) {
            return [<Icons.Alert />, "notification__warning"];
        } else if (props.error) {
            return [<Icons.X />, "notification__error"];
        } else {
            return [<Icons.Info />, "notification__generic"];
        }
    }());
    const cleanProps = omit(["warning", "error", "success", "tooltip"], props);
    return (
        <div
            {...cleanProps}
            className={"notification " + className + " " + props.className}
        >
            <div
                aria-label={props.tooltip}
                className="notification__icon"
                title={props.tooltip}
            >
                {icon}
            </div>
            <div className="notification__text">
                {props.children}
            </div>
        </div>
    );
}
Notification.propTypes = {
    children: PropTypes.node.isRequired,
    className: PropTypes.string,
    error: PropTypes.bool,
    success: PropTypes.bool,
    tooltip: PropTypes.string,
    warning: PropTypes.bool
};

/**
 * This just creates empty space to balance the layout, e.g. if there's a button
 * on one side of a centered element that's offsetting it.
 */
const PlaceholderButton = () => (
    <button
        className="button-ghost placeholder"
        aria-hidden
        disabled
    />
);
export {PlaceholderButton};

export function SortLabel({label, sortKey, data}) {
    function toggleDirAndSetKey() {
        data.setKey(sortKey);
        data.toggleDirection();
    }
    function setKeyOrToggleDir() {
        if (data.key === sortKey) {
            data.toggleDirection();
        } else {
            data.setKey(sortKey);
        }
    }
    return (
        <span className="buttons-on-hover">
            <PlaceholderButton />
            <button
                className="button-micro dont-hide button-text-ghost title-20"
                onClick={setKeyOrToggleDir}
            >
                {label}
            </button>
            <button
                className={classNames(
                    "button-ghost",
                    {"dont-hide": data.key === sortKey}
                )}
                onClick={toggleDirAndSetKey}
            >
                {(data.isDescending)
                    ? <Icons.ChevronUp />
                    : <Icons.ChevronDown />}
            </button>
        </span>
    );
}
SortLabel.propTypes = {
    data: PropTypes.object.isRequired,
    label: PropTypes.string.isRequired,
    sortKey: PropTypes.string.isRequired
};

/*******************************************************************************
 * Non-JSX functions
 ******************************************************************************/
// TODO: get rid of this.
export function findById(id, list) {
    return list.filter((x) => x.id === id)[0];
}
