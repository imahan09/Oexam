# Oexam — سامانه آزمون آنلاین

این پروژه اسکلت اولیه قابل استقرار Oexam با Next.js و Supabase است.

## راه‌اندازی محلی
1. Node.js نسخه 20 یا بالاتر نصب کنید.
2. در ریشه پروژه اجرا کنید: `npm install`
3. در Supabase یک پروژه بسازید.
4. محتوای `supabase/schema.sql` را در SQL Editor اجرا کنید.
5. فایل `.env.example` را به `.env.local` کپی کنید و URL و anon key پروژه Supabase را قرار دهید.
6. مدیر را ابتدا از صفحه ثبت‌نام بسازید؛ سپس در SQL Editor دستور انتهای schema را با ایمیل مدیر اجرا کنید.
7. اجرا: `npm run dev`

## انتشار رایگان
1. پروژه را در GitHub قرار دهید.
2. در Vercel یک حساب بسازید و مخزن GitHub را Import کنید.
3. Environment Variables زیر را در تنظیمات پروژه Vercel وارد کنید:
   - `NEXT_PUBLIC_SUPABASE_URL`
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY`
4. Deploy را بزنید. Vercel یک آدرس رایگان مانند `oexam-....vercel.app` می‌دهد.
5. در Supabase بخش Authentication > URL Configuration، آدرس Vercel را به Site URL و Redirect URLs اضافه کنید.

## وضعیت و محدودیت‌های این نسخه
- ثبت‌نام و ورود از طریق Supabase Auth انجام می‌شود.
- دیتابیس و سیاست‌های پایه دسترسی در `supabase/schema.sql` تعریف شده‌اند.
- فهرست آزمون‌ها و زمان‌بندی نمایش داده می‌شود.
- پنل ساخت آزمون در این اسکلت اولیه است؛ ویرایشگر کامل بانک سؤال، اجرای آزمون با تایمر سمت سرور، ذخیره امن پاسخ‌ها و تصحیح server-side باید پیش از استفاده آموزشی واقعی تکمیل و تست شود.
- تا زمانی که مدیر را در دیتابیس ارتقا نداده‌اید، ثبت‌نام عمومی فقط نقش دانش‌آموز می‌گیرد.
- کلید `service_role` را هرگز در کد مرورگر یا متغیرهای `NEXT_PUBLIC_` قرار ندهید.
