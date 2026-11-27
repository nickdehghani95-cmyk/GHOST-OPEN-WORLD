package com.nick.aigamer

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

private val Red = Color(0xFFE50919)
private val DeepRed = Color(0xFF7E0710)
private val Panel = Color(0xFF111114)
private val Ink = Color(0xFF080809)
private val Muted = Color(0xFFB8B8BD)

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.statusBarColor = android.graphics.Color.BLACK
        window.navigationBarColor = android.graphics.Color.BLACK
        requestedOrientation = android.content.pm.ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE
        setContent { NickApp() }
    }
}

@Composable
fun NickApp() {
    var page by remember { mutableStateOf("خانه") }
    var prompt by remember { mutableStateOf("") }
    var message by remember { mutableStateOf("") }
    var chat by remember { mutableStateOf(listOf("سلام! من Nick AI Gamer هستم. برای شروع پیام بنویس.")) }
    var adminNotice by remember { mutableStateOf("پنل مدیریت آماده اتصال به سرویس امن است.") }
    MaterialTheme(colorScheme = darkColorScheme(primary = Red, background = Ink, surface = Panel)) {
        Row(Modifier.fillMaxSize().background(Ink).padding(8.dp)) {
            Column(Modifier.weight(1f).fillMaxHeight()) {
                Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.padding(8.dp)) {
                    Box(Modifier.size(52.dp).background(DeepRed, RoundedCornerShape(50)), contentAlignment = Alignment.Center) {
                        Text("⚔", color = Color.White, fontSize = 28.sp)
                    }
                    Spacer(Modifier.width(10.dp))
                    Column {
                        Row {
                            Text("Nick ", color = Color.White, fontSize = 27.sp, fontWeight = FontWeight.Black)
                            Text("AI Gamer", color = Red, fontSize = 27.sp, fontWeight = FontWeight.Black)
                        }
                        Text("Your Ultimate AI Assistant", color = Muted, fontSize = 11.sp)
                    }
                }
                Row(Modifier.fillMaxWidth().padding(vertical = 5.dp), horizontalArrangement = Arrangement.spacedBy(5.dp)) {
                    listOf("خانه", "چت هوش مصنوعی", "عکس‌ساز", "پنل ادمین", "تنظیمات").forEach { item ->
                        Text(item, color = if (page == item) Color.White else Muted,
                            modifier = Modifier.weight(1f).background(if (page == item) DeepRed else Panel, RoundedCornerShape(9.dp))
                                .clickable { page = item }.padding(vertical = 10.dp), textAlign = TextAlign.Center, fontSize = 11.sp, fontWeight = FontWeight.Bold)
                    }
                }
                when (page) {
                    "چت هوش مصنوعی" -> ChatPanel(chat, message, { message = it }) {
                        if (message.isNotBlank()) {
                            chat = chat + "شما: $message" + "Nick AI: سرویس هوش مصنوعی هنوز به سرور متصل نشده است؛ پس از تنظیم اتصال فعال می‌شود."
                            message = ""
                        }
                    }
                    "عکس‌ساز" -> ImagePanel(prompt, { prompt = it })
                    "پنل ادمین" -> AdminPanel(adminNotice) { adminNotice = "برای مدیریت واقعی کاربران، باید سرور و ورود امن مدیر راه‌اندازی شود." }
                    "تنظیمات" -> InfoPanel()
                    else -> HomePanel { page = it }
                }
            }
        }
    }
}

@Composable
fun HomePanel(open: (String) -> Unit) {
    Row(Modifier.fillMaxSize(), horizontalArrangement = Arrangement.spacedBy(9.dp)) {
        Column(Modifier.weight(1.1f).fillMaxHeight().background(Panel, RoundedCornerShape(14.dp)).padding(12.dp)) {
            Text("Nick AI Gamer  ● آنلاین", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 16.sp)
            Spacer(Modifier.height(12.dp))
            Text("سلام! 😎", color = Color.White, fontSize = 18.sp)
            Text("من دستیار هوش مصنوعی Nick AI Gamer هستم.", color = Muted)
            Spacer(Modifier.weight(1f))
            Text("برای شروع، یکی از قابلیت‌ها را انتخاب کن.", color = Muted, fontSize = 12.sp)
        }
        Column(Modifier.weight(1.35f), verticalArrangement = Arrangement.spacedBy(9.dp)) {
            FeatureTile("چت با هوش مصنوعی", "گفت‌وگو و پرسش و پاسخ", Modifier.weight(1f)) { open("چت هوش مصنوعی") }
            FeatureTile("عکس‌ساز با هوش مصنوعی", "ساخت تصویر از توضیحات متنی", Modifier.weight(1f)) { open("عکس‌ساز") }
            FeatureTile("پنل ادمین", "تنظیمات و مدیریت", Modifier.weight(1f)) { open("پنل ادمین") }
        }
        Column(Modifier.weight(1f).fillMaxHeight().background(Panel, RoundedCornerShape(14.dp)).padding(12.dp)) {
            Text("👑 پنل ادمین", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 18.sp)
            Spacer(Modifier.height(12.dp))
            Text("NickAdmin", color = Color.White)
            Text("وضعیت: نمایشی", color = Color(0xFF45D36A))
            Spacer(Modifier.height(12.dp))
            Text("مدیریت کاربران", color = Muted)
            Text("مدیریت تصاویر", color = Muted)
            Text("گزارش فعالیت‌ها", color = Muted)
        }
    }
}

@Composable
fun FeatureTile(title: String, subtitle: String, modifier: Modifier = Modifier, click: () -> Unit) {
    Column(modifier.fillMaxWidth().border(1.dp, Red, RoundedCornerShape(13.dp))
        .background(Panel, RoundedCornerShape(13.dp)).clickable { click() }.padding(12.dp),
        horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.Center) {
        Text(title, color = Color.White, fontWeight = FontWeight.Bold, fontSize = 16.sp, textAlign = TextAlign.Center)
        Spacer(Modifier.height(5.dp))
        Text(subtitle, color = Muted, fontSize = 11.sp, textAlign = TextAlign.Center)
    }
}

@Composable
fun ChatPanel(chat: List<String>, message: String, onMessage: (String) -> Unit, send: () -> Unit) {
    Column(Modifier.fillMaxSize().background(Panel, RoundedCornerShape(14.dp)).padding(12.dp)) {
        Text("چت با هوش مصنوعی", color = Red, fontSize = 18.sp, fontWeight = FontWeight.Bold)
        LazyColumn(Modifier.weight(1f).fillMaxWidth()) {
            items(chat) { Text(it, color = Color.White, modifier = Modifier.padding(8.dp).background(Color(0xFF242428), RoundedCornerShape(10.dp)).padding(10.dp)) }
        }
        Row(verticalAlignment = Alignment.CenterVertically) {
            BasicTextField(message, onMessage, Modifier.weight(1f).background(Color(0xFF252529), RoundedCornerShape(10.dp)).padding(12.dp), textStyle = androidx.compose.ui.text.TextStyle(color = Color.White), decorationBox = { inner -> if (message.isEmpty()) Text("پیام خود را بنویسید...", color = Muted); inner() })
            Spacer(Modifier.width(8.dp))
            Button(onClick = send, colors = ButtonDefaults.buttonColors(containerColor = Red)) { Text("ارسال") }
        }
    }
}

@Composable
fun ImagePanel(prompt: String, onPrompt: (String) -> Unit) {
    Column(Modifier.fillMaxSize().background(Panel, RoundedCornerShape(14.dp)).padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Text("عکس‌ساز هوش مصنوعی", color = Red, fontSize = 20.sp, fontWeight = FontWeight.Bold)
        Text("توضیح تصویر موردنظرت را بنویس:", color = Color.White)
        BasicTextField(prompt, onPrompt, Modifier.fillMaxWidth().background(Color(0xFF242428), RoundedCornerShape(10.dp)).padding(14.dp), textStyle = androidx.compose.ui.text.TextStyle(color = Color.White), decorationBox = { inner -> if (prompt.isEmpty()) Text("مثلاً یک سامورایی در شهر نئونی...", color = Muted); inner() })
        Button(onClick = {}, colors = ButtonDefaults.buttonColors(containerColor = Red)) { Text("ساخت تصویر") }
        Text("برای تولید واقعی تصویر، اتصال امن به سرویس هوش مصنوعی لازم است.", color = Muted, fontSize = 12.sp)
    }
}

@Composable
fun AdminPanel(notice: String, action: () -> Unit) {
    Column(Modifier.fillMaxSize().background(Panel, RoundedCornerShape(14.dp)).padding(18.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Text("👑 پنل مدیریت", color = Red, fontSize = 22.sp, fontWeight = FontWeight.Bold)
        Text("مدیریت کاربران • تصاویر • تنظیمات هوش مصنوعی • گزارش فعالیت‌ها", color = Color.White)
        Text(notice, color = Muted)
        Button(onClick = action, colors = ButtonDefaults.buttonColors(containerColor = DeepRed)) { Text("وضعیت اتصال") }
    }
}

@Composable
fun InfoPanel() {
    Column(Modifier.fillMaxSize().background(Panel, RoundedCornerShape(14.dp)).padding(18.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
        Text("تنظیمات", color = Red, fontSize = 22.sp, fontWeight = FontWeight.Bold)
        Text("Nick AI Gamer • نسخه آزمایشی 0.1.0", color = Color.White)
        Text("چیدمان افقی خودکار فعال است.", color = Muted)
        Text("اتصال سرویس‌های هوش مصنوعی و ورود امن مدیر در مرحله بعد پیکربندی می‌شوند.", color = Muted)
    }
}
