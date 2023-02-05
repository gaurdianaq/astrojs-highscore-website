import type { Component, JSX } from "solid-js"

interface ILayoutProps {
	children: JSX.Element;
}

export const Layout: Component<ILayoutProps> = (props) => {
	return <>{props.children}</>
}