import NavBar from "../../components/NavBar";
import ContentSections from "../../components/ContentSections";
import Footer from "../../components/Footer";
import "../globals.css";

export const metadata = {
  title: "Environmental Protection & More",
  authors: [{ name: "Fouad" }],
  description:
    "Environmental protection, frontend cloud, API for Any Model, postgres development platform, and many other important topics.",
};

export default function Home() {
  return (
    <>
      <NavBar />
      <ContentSections />
      <Footer />
    </>
  );
}
