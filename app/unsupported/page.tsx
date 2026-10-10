export const metadata = {
  title: 'Unsupported browser',
  description:
    'Your browser appears to be out of date. Update for best performance and security.',
}

const GUIDE = 'https://www.whatismybrowser.com/guides/how-to-update-your-browser/'

export default function UnsupportedPage() {
  return (
    <main className="mx-auto flex min-h-screen max-w-2xl flex-col justify-center px-6 py-16 text-center">
      <h1 className="text-3xl font-semibold">Your browser needs an update</h1>
      <p className="mt-4 text-base text-muted-foreground">
        This browser or device is out of date, so some features may not work correctly. Update your
        browser for better performance and security.
      </p>
      <div className="mt-8">
        <a
          className="rounded-md bg-primary px-4 py-2 text-primary-foreground"
          href={GUIDE}
          target="_blank"
          rel="noopener noreferrer"
        >
          How to update your browser
        </a>
      </div>
    </main>
  )
}
