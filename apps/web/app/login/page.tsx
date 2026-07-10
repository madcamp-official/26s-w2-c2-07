import Link from "next/link";
import { Feather } from "lucide-react";

export default function Login() {
  return (
    <main className="login">
      <section className="login-story">
        <Link href="/" className="brand light">
          Nook<span>.</span>
        </Link>
        <div>
          <Feather />
          <p>
            “마음에 머문 것을
            <br />한 문장씩 꺼내 놓는 곳.”
          </p>
          <small>생각이 글이 되는 가장 조용한 시간</small>
        </div>
      </section>
      <section className="login-form">
        <div>
          <p className="eyebrow">WELCOME TO NOOK</p>
          <h1>
            당신의 이야기가
            <br />
            머무를 자리를 만들어요.
          </h1>
          <p className="subtitle">
            흩어진 영감을 모으고, 한 편의 글로 이어가세요.
          </p>
          <Link href="/" className="google">
            <span>G</span> Google로 계속하기
          </Link>
          <p className="terms">
            계속하면 Nook의 이용약관 및 개인정보처리방침에 동의하게 됩니다.
          </p>
          {/* TODO(backend): Supabase Google OAuth 로그인 및 인증 콜백과 연결해야 합니다. */}
        </div>
      </section>
    </main>
  );
}
