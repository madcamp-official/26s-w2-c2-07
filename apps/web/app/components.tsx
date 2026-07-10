'use client';
import Link from 'next/link';
import {usePathname} from 'next/navigation';
import {Bell,BookOpen,FolderKanban,Home,LogOut,Menu,Plus,Settings,UserRound,X} from 'lucide-react';
import {useState} from 'react';

const nav=[['/',Home,'홈'],['/captures',BookOpen,'글감함'],['/projects',FolderKanban,'프로젝트'],['/profile',UserRound,'프로필']] as const;
export function Shell({children}:{children:React.ReactNode}){
 const path=usePathname(); const [open,setOpen]=useState(false);
 return <div className="shell"><button className="mobile-menu" onClick={()=>setOpen(true)} aria-label="메뉴 열기"><Menu/></button><aside className={`sidebar ${open?'open':''}`}><div className="brand-row"><Link href="/" className="brand">Nook<span>.</span></Link><button className="mobile-close" onClick={()=>setOpen(false)}><X/></button></div><p className="brand-note">생각이 머무는 작은 공간</p><nav>{nav.map(([href,Icon,label])=><Link onClick={()=>setOpen(false)} className={(href==='/'?path===href:path.startsWith(href))?'active':''} href={href} key={href}><Icon/><span>{label}</span></Link>)}</nav><div className="side-bottom"><Link href="/profile"><Settings/><span>설정</span></Link><Link href="/login"><LogOut/><span>로그아웃</span></Link><div className="mini-profile"><div className="avatar">누</div><div><b>김누리</b><small>nuri@nook.kr</small></div></div></div></aside><main className="main"><header className="topbar"><div/><div><button className="icon-btn" aria-label="알림"><Bell/></button><Link href="/profile" className="avatar">누</Link></div></header>{children}</main></div>
}
export function PageHead({eyebrow,title,desc,action}:{eyebrow?:string,title:React.ReactNode,desc?:string,action?:React.ReactNode}){return <div className="page-head"><div>{eyebrow&&<p className="eyebrow">{eyebrow}</p>}<h1>{title}</h1>{desc&&<p className="subtitle">{desc}</p>}</div>{action}</div>}
export function TypeBadge({type}:{type:'text'|'image'|'link'}){return <span className={`type type-${type}`}>{type==='text'?'조각글':type==='image'?'사진':'링크'}</span>}
export function AddButton({href='/captures/new',children='새 글감'}:{href?:string,children?:React.ReactNode}){return <Link className="button primary" href={href}><Plus/> {children}</Link>}
