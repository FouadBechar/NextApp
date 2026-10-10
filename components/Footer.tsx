"use client";
import SafeImage from "./ui/SafeImage";

const fb = "/assets/fb.svg";
const x = "/assets/x.svg";
const git = "/assets/git.svg";
const youtb = "/assets/youtb.svg";

export default function Footer() {
  return (
    <footer id="text11" className="foter">
      <span className="footer01sp">
        <a
          href="https://www.facebook.com/FouadBechar8"
          target="_blank"
          rel="noopener noreferrer"
          aria-label="Follow on Facebook"
        >
          <SafeImage
            className="img321"
            src={fb}
            alt="image_fb"
            width={32}
            height={32}
          />
        </a>
        <a
          href="https://x.com/FouadBechar"
          target="_blank"
          rel="noopener noreferrer"
          aria-label="Follow on X (Twitter)"
        >
          <SafeImage
            className="img321"
            src={x}
            alt="image_x"
            width={32}
            height={32}
          />
        </a>

        {/* <a
          href="https://www.youtube.com/channel/UChqHFHvmCFfr1JDnRPKtEBg"
          target="_parent"
          aria-label="Follow on YouTube"
        >
          <SafeImage
            className="img321"
            src={youtb}
            alt="image_youtb"
            width={32}
            height={32}
          />
        </a> */}
        
        <a
          href="https://github.com/FouadBechar"
          target="_blank"
          rel="noopener noreferrer"
          aria-label="Follow on GitHub"
        >
          <SafeImage
            className="img321"
            src={git}
            alt="image_git"
            width={32}
            height={32}
          />
        </a>
      </span>
      <div className="pr0101">
        <p>
          {" "}
          <a className="apr0101" href="/privacy/" target="_parent">
            Privacy Policy
          </a>
        </p>
        <p className="apr0102">&nbsp;&amp;&nbsp;</p>
        <p id="open-btn"> Contact us </p>
      </div>
    </footer>
  );
}
