# -*- coding: utf-8 -*-
"""Shared labeled-export formatters used by REST and MCP."""
from typing import List, Optional
import json

from app.models.chat import StagingConversation, CustomConversation


# 价格相关关键词列表
PRICE_KEYWORDS = [
    # 价格金额
    r'\d+元', r'\d+块', r'¥\d+', r'\$\d+',
    r'原价', r'现价', r'优惠价', r'特价', r'折扣',
    r'打折', r'立减', r'满减', r'返现',
    # 具体金额模式
    r'\d+\.\d+元', r'\d+千', r'\d+万',
    r'几千', r'几百', r'几万',
    # 费用类
    r'学费', r'报名费', r'定金', r'尾款', r'全款',
    r'分期', r'首付', r'月供',
    # 促销相关
    r'限时', r'秒杀', r'抢购', r'活动价',
    r'今天.*价', r'明天.*涨价',
]


def _contains_price_info(text: str) -> bool:
    """检查文本是否包含价格信息"""
    import re
    if not text:
        return False
    for pattern in PRICE_KEYWORDS:
        if re.search(pattern, text, re.IGNORECASE):
            return True
    return False


def _desensitize_price(text: str) -> str:
    """
    脱敏处理课程价格信息（保留薪资信息）
    
    脱敏规则：
    - 课程价格：3999、4999、5999、6999 等明确课程价格 → 脱敏
    - 优惠相关：原价xxx、优惠价xxx、活动价xxx → 脱敏
    - 报名费用：报名费、学费、定金、尾款 + 金额 → 脱敏
    
    保留：
    - 薪资信息：10k、20k、25k、30k 等 → 保留
    - 用户自述薪资：现在多少k、目前xx万 → 保留
    """
    import re
    if not text:
        return text
    
    result = text
    
    # ===== 需要脱敏的课程价格 =====
    
    # 1. 常见课程价格（千位结尾的价格 + 常见优惠价）
    # 注意：Python 3 中 \b 使用 Unicode 边界，中文字符属于 \w，
    # 所以 \b3999\b 无法匹配 "说3999"。改用 (?<!\d) 和 (?!\d)
    COURSE_PRICES = [
        '1999', '2999', '3999', '4999', '5999', '6999', '7999', '8999', '9999',
        '1888', '2888', '3888', '4888', '5888', '6888', '7888', '8888', '9888',
        '4499', '4299', '3599', '5499', '5299',  # 常见优惠价格
        '1000', '2000', '3000', '4000', '5000', '6000', '7000', '8000', '9000',  # 整千
        '1500', '2500', '3500', '4500', '5500',  # 整千五
    ]
    for price in COURSE_PRICES:
        result = re.sub(rf'(?<!\d){price}(?!\d)', '[课程价格]', result)
    
    # 1.5 通用4位数价格（在明确价格语境中）
    result = re.sub(r'是(\d{4})(?:[？\?]|$)', r'是[课程价格]', result)
    # 更多价格语境：就是xxxx了、来就xxxx
    result = re.sub(r'(?:就是|来就|直接|今天|今晚.*?是)(\d{4,5})', '[课程价格]', result)
    
    # 1.6 开票/发票金额（如 "唐铭志 3000"、"开票 5000"）
    result = re.sub(r'(开票|发票|报销|金额).*?(\d{3,5})', lambda m: m.group(0).replace(m.group(2), '[金额]'), result)
    
    # 1.7 个人姓名脱敏（中文姓名 2-4 字 + 紧跟金额或空格+金额）
    result = re.sub(r'[\u4e00-\u9fa5]{2,4}\s+\[课程价格\]', '[学员] [课程价格]', result)
    result = re.sub(r'[\u4e00-\u9fa5]{2,4}\s+\[金额\]', '[学员] [金额]', result)
    result = re.sub(r'[\u4e00-\u9fa5]{2,4}\s+\d{4,5}', '[学员] [金额]', result)
    
    # 2. 明确的课程价格语境（优惠价、原价、现价、活动价 + 数字）
    result = re.sub(r'(原价|现价|优惠价?|特价|活动价|首发价?)[\s:：]*(\d{3,5})', r'\1[价格详询]', result)
    
    # 3. 报名费用相关（学费、报名费、定金、尾款 + 数字）
    result = re.sub(r'(学费|报名费|定金|尾款|全款)[\s:：]*(\d{3,5})', r'\1[价格详询]', result)
    
    # 4. 涨价/降价/优惠金额语境
    result = re.sub(r'(涨了?|降了?|优惠了?|便宜了?|减了?)[\s]?(\d{3,5})', r'\1[若干]', result)
    
    # 5. 给你xx价格的报价语境
    result = re.sub(r'给你[\s]?(\d{4,5})', '给你[优惠价]', result)
    result = re.sub(r'(\d{4,5})[\s]?给你', '[优惠价]给你', result)
    
    # ===== 致命红线内容处理 =====
    
    # 6. 直接报价模式（必须脱敏，否则模型学会报价）
    result = re.sub(r'都是(\d{4,5})来的', '都是[课程价格]来的', result)
    result = re.sub(r'直接转我[吧]?(\d{4,5})', '直接转[价格详询]', result)
    result = re.sub(r'转我(\d{4,5})', '转[价格详询]', result)
    result = re.sub(r'我亏(\d{3,5})', '我亏[若干]', result)
    
    # 7. 支付方式询问（替换为标准话术）
    result = re.sub(r'微信还是支付宝[还是信用卡]*', '付款方式私聊教务', result)
    result = re.sub(r'支付宝[账号帐号]?', '付款方式私聊教务', result)
    result = re.sub(r'直接转就?行了?', '直接找教务办理', result)
    
    # 8. 垃圾噪音过滤
    # 飞书用户名等无效内容
    result = re.sub(r'飞书用户名[是]?多少', '信息已私发', result)
    result = re.sub(r'你飞书用户名', '你的账号信息', result)
    
    # URL链接替换 → 直接根据上下文替换为描述性文字（不再留占位符）
    result = re.sub(r'https?://[^\s\u4e00-\u9fa5]+', '', result)
    # 协议相对URL (//domain.com/...)
    result = re.sub(r'(?<![:\w])//[a-zA-Z0-9\-]+\.[a-zA-Z0-9\-./\w]+', '', result)
    # 已知域名直接匹配（飞书、抖音等） - 按行处理以应对换行拆分的URL
    result = re.sub(r'jianxuanguan[.\w/\-]*', '', result)
    result = re.sub(r'feishu\.cn[/\w\-]*', '', result)
    # 清理 URL hash/路径残留（如 SgISw51EKiY5L0k 等看起来像 URL path 的长字符串）
    # 匹配独占一行的、看起来像 URL 路径的纯英数字串 (10+ 字符，混有大小写)
    result = re.sub(r'^[A-Za-z0-9/\-_]{10,}$', '', result, flags=re.MULTILINE)
    # 清理 //\n 残留
    result = re.sub(r'//\s*\n', '\n', result)
    
    # 清理替换后的空行和多余空格
    result = re.sub(r'\n\s*\n\s*\n', '\n\n', result)
    result = re.sub(r'  +', ' ', result)
    
    # ===== 保留薪资信息 =====
    # 以下模式不处理，保持原样：
    # - XXk、XX万（薪资格式）
    # - 多少k、目前XX（用户自述）
    
    return result


def _replace_resource_links(text: str) -> str:
    """
    清理文本中残留的 [资料链接] 占位符
    
    策略：
    - 如果 [资料链接] 前面已有描述（如 "Ai岗位解析（视频）"），直接删除占位符
    - 如果整行只有 [资料链接]，删除整行
    - 清理多余空行
    """
    import re
    if not text or "[资料链接]" not in text:
        return text
    
    # 按行处理
    lines = text.split('\n')
    cleaned_lines = []
    for line in lines:
        stripped = line.strip()
        # 整行只是 [资料链接]（可能前后有空格）→ 跳过该行
        if stripped == '[资料链接]':
            continue
        # 行内包含 [资料链接] → 删除占位符
        if '[资料链接]' in stripped:
            line = line.replace('[资料链接]', '').strip()
            # 如果删除后行变空了，跳过
            if not line:
                continue
        cleaned_lines.append(line)
    
    result = '\n'.join(cleaned_lines)
    # 清理连续空行
    result = re.sub(r'\n{3,}', '\n\n', result)
    return result.strip()


# 标准价格回复模板（符合系统提示词硬性红线）
STANDARD_PRICE_RESPONSE = """价格这块懂王Ai经常有活动
我得先看你合不合适带
合适的话我推个教务老师给你
你找他领最新优惠"""

# 价格违规关键词（扩展版）
# 注意：不包含 \d+k 因为薪资信息（20k）需要保留
PRICE_VIOLATION_KEYWORDS = [
    r'改价', r'折扣', r'多少钱',
    r'分期', r'\d+元', r'\d+块', r'\d+w',
    r'首发.*优惠', r'活动.*价', r'给.*优惠',
    # 脱敏后残留的占位符 → 说明该消息涉及价格，应整体替换
    r'\[课程价格\]', r'\[优惠价\]', r'\[若干\]', r'\[金额\]', r'\[价格详询\]',
    # 直接报价语境
    r'卖.*?[六七八九]\d*千', r'涨到.*?[六七八九]\d*千',
    r'价格.*?[低太]', r'价格.*?定',
    r'恢复\d{4}', r'涨价',
]

# 禁用标点符号
FORBIDDEN_PUNCTUATION = ['。', '，', '！', '？', '、', '；', '：', '"', '"', ''', ''']


def _validate_and_fix_gpt_response(text: str, category: str = "sales") -> tuple:
    """
    验证并自动修复 GPT 回复，确保符合系统提示词规则

    Args:
        text: GPT 回复文本
        category: 对话类别

    Returns:
        (fixed_text, violations): 修复后的文本和违规列表
    """
    import re

    violations = []
    fixed_text = text

    if not text:
        return text, violations

    # 规则 1: 价格关键词检测（最高优先级）
    for pattern in PRICE_VIOLATION_KEYWORDS:
        if re.search(pattern, fixed_text, re.IGNORECASE):
            violations.append('price_violation')
            # 直接替换为标准回复
            return STANDARD_PRICE_RESPONSE, violations

    # 规则 1.5: 禁词替换（"您" → "你"）
    if '您' in fixed_text:
        violations.append('forbidden_word')
        fixed_text = fixed_text.replace('您', '你')
    
    # 规则 1.6: 移除 "亲" 开头的称呼
    if '亲' in fixed_text:
        violations.append('forbidden_word')
        fixed_text = re.sub(r'亲[，,\s]?', '', fixed_text)

    # 规则 2: 移除禁用标点符号
    for punct in FORBIDDEN_PUNCTUATION:
        if punct in fixed_text:
            violations.append('punctuation')
            fixed_text = fixed_text.replace(punct, '')

    # 规则 3: 拆分超长行（每行不超过15字）
    lines = fixed_text.split('\n')
    new_lines = []

    for line in lines:
        if len(line) > 15:
            violations.append('line_length')
            # 智能拆分：优先在空格处拆分
            if ' ' in line:
                words = line.split(' ')
                current_line = ''
                for word in words:
                    if len(current_line) + len(word) + 1 <= 15:
                        current_line += (' ' if current_line else '') + word
                    else:
                        if current_line:
                            new_lines.append(current_line)
                        current_line = word
                if current_line:
                    new_lines.append(current_line)
            else:
                # 无空格，每15字强制拆分
                for i in range(0, len(line), 15):
                    new_lines.append(line[i:i+15])
        else:
            new_lines.append(line)

    fixed_text = '\n'.join(new_lines)

    return fixed_text, violations


def _clean_conversation_for_training(conversations: list, desensitize_price: bool = True, validate_style: bool = True, min_turns: int = 2, max_turns: int = 40) -> list:
    """
    清洗对话数据，确保符合训练要求：
    1. 修复 gpt 先开口的问题（在前面补充一个 human 消息）
    2. 确保对话以 gpt 回复结束（移除末尾的 human 消息）
    3. 脱敏价格信息（保持与 system prompt 一致）
    4. 验证并修复风格问题（标点、行长度、价格违规）
    5. 过滤过短对话（少于 min_turns 轮对话）
    6. 拆分过长对话（超过 max_turns 条消息）

    Args:
        conversations: 对话列表，格式为 [{"from": "system/human/gpt", "value": "..."}]
        desensitize_price: 是否进行价格脱敏
        validate_style: 是否进行风格验证和修复
        min_turns: 最少对话轮次（不含 system），默认 2 条消息（1轮对话）
        max_turns: 最多对话轮次（不含 system），超过则拆分，默认 40 条消息

    Returns:
        清洗后的对话列表（如果过长会返回第一段，其他段会被丢弃）
    """
    if not conversations or len(conversations) < 1:
        return []
    
    result = []
    
    # 分离 system 消息和对话消息
    system_msg = None
    dialog_msgs = []
    
    for msg in conversations:
        role = msg.get("from", "")
        if role == "system":
            system_msg = msg
        else:
            dialog_msgs.append(msg)
    
    # 如果只有 system 消息或没有对话，返回空
    if len(dialog_msgs) < 1:
        return []
    
    # 处理1: 修复 gpt 先开口的问题
    # 如果第一条非 system 消息是 gpt，在前面补充一个 human 消息
    if dialog_msgs[0].get("from") == "gpt":
        dialog_msgs.insert(0, {
            "from": "human",
            "value": "你好"
        })
    
    # 处理2: 确保对话以 gpt 回复结束
    # 移除末尾连续的 human 消息
    while dialog_msgs and dialog_msgs[-1].get("from") == "human":
        dialog_msgs.pop()
    
    # 处理5: 过滤过短对话（新增）
    # 至少需要 min_turns 条消息（例如：1轮对话 = human + gpt = 2条消息）
    if len(dialog_msgs) < min_turns:
        return []
    
    # 处理6: 拆分过长对话（新增）
    # 如果对话超过 max_turns，只保留前 max_turns 条消息
    # 确保最后一条是 gpt 的回复
    if len(dialog_msgs) > max_turns:
        # 截取前 max_turns 条
        dialog_msgs = dialog_msgs[:max_turns]
        
        # 确保最后一条是 gpt 回复
        while dialog_msgs and dialog_msgs[-1].get("from") == "human":
            dialog_msgs.pop()
        
        # 再次检查长度
        if len(dialog_msgs) < min_turns:
            return []
    
    # 处理3: 价格脱敏（对所有消息生效，包括 human 和 gpt）
    if desensitize_price:
        for msg in dialog_msgs:
            msg["value"] = _desensitize_price(msg.get("value", ""))

    # 处理3.5: 清理残留的 [资料链接] 占位符
    for msg in dialog_msgs:
        msg["value"] = _replace_resource_links(msg.get("value", ""))

    # 处理4: 风格验证和修复
    if validate_style:
        for msg in dialog_msgs:
            if msg.get("from") == "gpt":
                original = msg.get("value", "")
                fixed, violations = _validate_and_fix_gpt_response(original)
                msg["value"] = fixed

    # 处理7: 最终清理 - 确保没有任何残留占位符/脏数据
    import re as _re
    WECHAT_EMOJIS = {
        '[捂脸]', '[破涕为笑]', '[坏笑]', '[旺柴]', '[呲牙]', '[害羞]',
        '[可怜]', '[苦涩]', '[流泪]', '[撇嘴]', '[社会社会]', '[强]',
        '[抱拳]', '[OK]', '[嘿哈]', '[机智]', '[加油]', '[微笑]', '[若干]',
    }
    DANGEROUS_PLACEHOLDERS = ['[课程价格]', '[优惠价]', '[金额]', '[价格详询]', '[学员]']
    
    for msg in dialog_msgs:
        value = msg.get("value", "")
        
        # 清理残留占位符（非微信表情的方括号内容）
        def _clean_bracket(m):
            full = m.group(0)
            if full in WECHAT_EMOJIS:
                return full
            if full in DANGEROUS_PLACEHOLDERS:
                return ''
            return full
        
        value = _re.sub(r'\[[^\]]+\]', _clean_bracket, value)
        
        # 清理 assistant 消息中的 您
        if msg.get("from") == "gpt":
            value = value.replace('您', '你')
        
        # 清理多余空行和空格
        value = _re.sub(r'\n\s*\n\s*\n', '\n\n', value)
        value = _re.sub(r'  +', ' ', value)
        value = value.strip()
        
        msg["value"] = value
    
    # 过滤掉内容变空的消息
    dialog_msgs = [m for m in dialog_msgs if m.get("value", "").strip()]
    
    # 再次确保以 human 开头、gpt 结尾
    if dialog_msgs and dialog_msgs[0].get("from") != "human":
        dialog_msgs.insert(0, {"from": "human", "value": "你好"})
    while dialog_msgs and dialog_msgs[-1].get("from") == "human":
        dialog_msgs.pop()
    
    if len(dialog_msgs) < min_turns:
        return []

    # 重新组装结果
    if system_msg:
        result.append(system_msg)
    result.extend(dialog_msgs)
    
    return result



def _clean_content_for_export(text: str, role: str = None, context_history: List[str] = None) -> str:
    """
    导出前清洗文本
    1. 移除角色前缀 (如 "我:", "张三:", "徒弟-🎉JasonZhuang🎉:")
    2. 移除混入的其他角色消息行
    3. 移除重复的上文 (如 Assistant 回复包含了 User 的问题)
    """
    if not text:
        return ""
    
    import re
    
    # 1. 移除角色前缀（支持 emoji 和长用户名，最大 30 字符）
    # 匹配行首的 "Name: " 或 "Name："，Name 可包含中文、emoji、字母、数字、特殊符号
    cleaned = re.sub(r'(^|\n)[^\n:：]{1,30}[:：][ \t]*', r'\1', text)
    
    # 2. 对 assistant 内容：移除混入的其他人消息行
    # 检测模式：行首是 "某人名: 内容" 的行属于 user，需要移除
    if role == "assistant":
        lines = cleaned.split('\n')
        assistant_lines = []
        for line in lines:
            stripped = line.strip()
            # 跳过以角色前缀开头的行（他人消息混入）
            if re.match(r'^[^\n:：]{1,30}[:：]\s', stripped):
                continue
            # 跳过以 "我:" 开头的行（自己的消息在 conversation_json 中不应有前缀）
            if re.match(r'^我[:：]\s*', stripped):
                # 保留 "我:" 后面的内容
                content_after = re.sub(r'^我[:：]\s*', '', stripped)
                if content_after:
                    assistant_lines.append(content_after)
                continue
            if stripped:
                assistant_lines.append(stripped)
        cleaned = '\n'.join(assistant_lines)
    
    # 对 user 内容：只清理首行的角色前缀
    if role == "user":
        cleaned = re.sub(r'^[^\n:：]{1,30}[:：][ \t]*', '', cleaned.strip())
    
    # 3. 移除重复 (简单的头部重叠检测)
    if context_history:
        last_turn = context_history[-1] if context_history else ""
        if last_turn and len(last_turn) > 5:
            # 去掉可能的角色前缀后再比对
            last_turn_clean = re.sub(r'^[^:：]*[:：]\s*', '', last_turn).strip()
            
            # 检查 text 是否以 last_turn 开头
            if cleaned.strip().startswith(last_turn_clean):
                cleaned = cleaned.replace(last_turn_clean, "", 1).strip()
            # 或者 text 的前50个字符包含 last_turn 的后50个字符 (重叠)
            elif len(last_turn_clean) > 10 and last_turn_clean[-10:] in cleaned[:20]:
                 cleaned = cleaned.replace(last_turn_clean[-10:], "", 1).strip()

    # 清理多余空行
    cleaned = re.sub(r'\n\s*\n\s*\n', '\n\n', cleaned)
    return cleaned.strip()


def _format_staging_item(item: StagingConversation, format: str, include_system_prompt: bool = True) -> Optional[dict]:
    """
    将暂存区数据转换为指定的导出格式
    """
    # 优先解析结构化数据
    conversation_data = None
    if item.conversation_json:
        try:
            conversation_data = json.loads(item.conversation_json) if isinstance(item.conversation_json, str) else item.conversation_json
        except:
            pass
            
    # 获取清洗后的基础文本 (作为 fallback)
    content = item.cleaned_text or item.original_text
    
    # 如果没有结构化数据且文本太短，直接丢弃
    if (not conversation_data) and (not content or len(content.strip()) < 5):
        return None
    
    # 获取类别和系统提示
    category = item.human_category or item.auto_category or 'sales'
    system_prompt = _get_system_prompt_for_category(category) if include_system_prompt else None
    
    # -------------------------------------------------------------
    # 构造标准 Messages 列表 (中间格式)
    # -------------------------------------------------------------
    messages = []
    
    if system_prompt:
        messages.append({"role": "system", "content": system_prompt})
        
    if conversation_data and isinstance(conversation_data, list) and len(conversation_data) > 0:
        # 策略 A: 使用结构化 Conversation JSON (质量最高)
        history_context = []
        for turn in conversation_data:
            role = turn.get("role", "user")
            turn_content = turn.get("content", "")
            
            # 清洗
            clean_content = _clean_content_for_export(turn_content, role, history_context)
            
            if clean_content:
                # 映射角色
                std_role = "assistant" if role in ["assistant", "gpt", "model"] else "user"
                messages.append({"role": std_role, "content": clean_content})
                # 只有 User 的话才作为 history 防止 Assistant 自我重复用于检测
                if std_role == "user":
                    history_context.append(clean_content)
                    
    else:
        # 策略 B: 使用 Question / Answer 字段 (次优)
        question = item.human_question or item.auto_question
        answer = item.human_answer or item.auto_answer
        
        if question and answer:
             q_clean = _clean_content_for_export(question, "user")
             a_clean = _clean_content_for_export(answer, "assistant", [q_clean])
             
             messages.append({"role": "user", "content": q_clean})
             messages.append({"role": "assistant", "content": a_clean})
        else:
             # 策略 C: 只有 Raw Content，尝试不做任何处理直接放入 (最低质量)
             # 但为了防止全是 User: ... Me: ... 这种混杂，尝试做一点提取
             # 如果内容太乱，建议直接丢弃或者人工处理，但这里先尽量清洗
             raw_clean = _clean_content_for_export(content, "assistant") # 假设整段都是 assistant 输出
             messages.append({"role": "user", "content": "请总结这段对话"})
             messages.append({"role": "assistant", "content": raw_clean})

    # 过滤掉没有实质对话的
    if len(messages) <= 1: # 只有 system prompt
        return None

    # -------------------------------------------------------------
    # 转换为最终格式
    # -------------------------------------------------------------
    
    if format == "sharegpt":
        conversations = []
        for msg in messages:
            role_map = {"user": "human", "assistant": "gpt", "system": "system"}
            if msg["role"] in role_map:
                conversations.append({"from": role_map[msg["role"]], "value": msg["content"]})
        
        # 应用训练数据清洗：修复gpt先开口、移除不完整对话、价格脱敏、过滤过短/过长对话
        conversations = _clean_conversation_for_training(
            conversations, 
            desensitize_price=True,
            validate_style=True,
            min_turns=4,  # 至少 4 条消息（2轮对话）
            max_turns=40  # 最多 40 条消息
        )
        
        # 如果清洗后没有有效对话，返回 None
        if len(conversations) < 2:
            return None
        
        result = {
            "id": str(item.id),
            "conversations": conversations,
            "category": category,
            "quality": "high"
        }
        
        return result
    
    elif format == "alpaca":
        # Alpaca 只能存一组对话，取第一组 User/Assistant
        user_msg = next((m["content"] for m in messages if m["role"] == "user"), "")
        assist_msg = next((m["content"] for m in messages if m["role"] == "assistant"), "")
        
        return {
            "instruction": user_msg or "请分析以下内容",
            "input": "",
            "output": assist_msg,
            "category": category
        }
    
    elif format == "rag":
        # RAG 知识库格式：提取 question/answer 对
        # 优先从已清洗的 messages 中提取
        user_msgs = [m["content"] for m in messages if m["role"] == "user"]
        assist_msgs = [m["content"] for m in messages if m["role"] == "assistant"]
        
        question = ""
        answer = ""
        
        if user_msgs and assist_msgs:
            # 策略 A: 从结构化 messages 提取
            question = user_msgs[0]
            answer = "\n".join(assist_msgs)
        else:
            # 策略 B: Fallback 到 question/answer 字段
            raw_question = item.human_question or item.auto_question or ''
            raw_answer = item.human_answer or item.auto_answer or ''
            if raw_question and raw_answer:
                question = raw_question
                answer = raw_answer
        
        if not question or not answer:
            return None
        
        # 清洗角色前缀和混入的其他人消息
        question = _clean_content_for_export(question, "user")
        answer = _clean_content_for_export(answer, "assistant", [question])
        
        if not question or not answer:
            return None
        
        # 价格脱敏
        question = _desensitize_price(question)
        answer = _desensitize_price(answer)
        # 清理残留占位符
        question = _replace_resource_links(question)
        answer = _replace_resource_links(answer)
        # 风格验证（仅对 answer 做风格修复）
        answer, _ = _validate_and_fix_gpt_response(answer, category)
        
        return {
            "question": question.strip(),
            "answer": answer.strip(),
            "category": category
        }
    
    elif format in ["openai", "jsonl"]:
        # OpenAI 格式：先转换为 sharegpt 格式清洗，再转回来
        conversations = []
        for msg in messages:
            role_map = {"user": "human", "assistant": "gpt", "system": "system"}
            if msg["role"] in role_map:
                conversations.append({"from": role_map[msg["role"]], "value": msg["content"]})
        
        # 应用训练数据清洗：过滤过短/过长对话、价格脱敏
        conversations = _clean_conversation_for_training(
            conversations, 
            desensitize_price=True,
            validate_style=True,
            min_turns=4,  # 至少 4 条消息（2轮对话）
            max_turns=40  # 最多 40 条消息
        )
        
        # 如果清洗后没有有效对话，返回 None
        if len(conversations) < 2:
            return None
        
        # 转回 OpenAI messages 格式
        cleaned_messages = []
        for conv in conversations:
            role_map = {"human": "user", "gpt": "assistant", "system": "system"}
            cleaned_messages.append({
                "role": role_map[conv["from"]],
                "content": conv["value"]
            })
        
        return {"messages": cleaned_messages}
    
    return None


def _get_system_prompt_for_category(category: str) -> str:
    """根据类别获取系统提示"""
    prompts = {
        "sales": """我是懂王Ai的懂小智，比懂王更懂Ai。我不是客服，是助你转行的职业导师。

【说话风格】
说话极简，像微信聊天一样频繁换行。每行不超过15字。严禁标点，严禁说"亲"或"您"。

【硬性红线】
严禁说出任何具体价格数字。一旦涉及钱、优惠或分期，统一回复："价格这块懂王Ai经常有活动。我得先看你合不合适带，合适的话我推个教务老师给你，你找他领最新优惠。"

【成交逻辑】
1. 姿态要高：用户问课，不直接答。先查背景（学历、专业、技术栈、薪资）。不合要求的直接劝退，不浪费时间。
2. 制造危机：强调"Java/前端已死"、"年轻人要干有前途的行业"。
3. 引导人工：背景合适且意向强的，直接要电话或推教务，闭环成交。""",

        "course": """我是懂王Ai的懂小智，比懂王更懂Ai。负责课程咨询。

【说话风格】
说话极简，像微信聊天一样频繁换行。每行不超过15字。严禁标点，严禁说"亲"或"您"。

【课程体系】
1. 从Python零基础讲起，有编程基础的可以跳。
2. 核心: AI应用开发(Agent/RAG/LangChain/MCP)，100%纯血AI。
3. 项目实战为主，不是纯理论。
4. 录播+直播答疑，灵活安排，上班也能学。
5. 3个月左右学完，课程持续迭代，3年有效期。
6. 不懂的群里问，有助教和老师答疑。

【红线】涉及价格统一用标准回复，不说具体数字。""",

        "objection": """我是懂王Ai的懂小智，比懂王更懂Ai。擅长化解学员顾虑。

【说话风格】
说话极简，像微信聊天一样频繁换行。每行不超过15字。严禁标点，严禁说"亲"或"您"。

【常见异议处理策略】
1. 太贵 → 投资回报(一个月工资回本) + 标准价格回复
2. 零基础学不会 → 看有没有兴趣，需要多花时间，Python从0讲
3. 年龄大 → 30多很年轻，还能干10年，选择大于努力
4. 专科学历 → 本科够用，专科也能找，现在没人竞争
5. 没时间 → 上班摸鱼学，录播随时看，2小时够用
6. 想考虑 → 别犹豫，年后涨价，机会不等人
7. 不信培训 → 7天无理由退，课程质量说话

【红线】涉及价格统一用标准回复，不说具体数字。""",

        "closing": """我是懂王Ai的懂小智，比懂王更懂Ai。负责引导成交。

【说话风格】
说话极简，像微信聊天一样频繁换行。每行不超过15字。严禁标点，严禁说"亲"或"您"。

【成交流程】
1. 用户决定报名 → 欢迎 + 要电话开课
2. 老学员续费 → 感谢支持 + 优惠
3. 犹豫后决定 → 肯定选择 + 赶紧开始
4. 开课后 → 群公告文档权限 + 开课说明

【红线】涉及价格统一用标准回复，不说具体数字。""",

        "followup": """我是懂王Ai的懂小智，比懂王更懂Ai。负责学员售后服务。

【说话风格】
说话极简，像微信聊天一样频繁换行。每行不超过15字。严禁标点，严禁说"亲"或"您"。

【售后场景】
1. 学习进度 → 不急，多看几遍，不懂群里问
2. 设备绑定 → 给你加，最多3个设备
3. 发票 → 可以开，软件服务类，信息发我
4. 退款 → 支持7天无理由，了解原因，走流程
5. 课程更新 → 持续迭代，同步到你账号
6. 找工作 → 简历我帮你看，先过我面试，抓紧投""",

        "qa": """我是懂王Ai的懂小智，比懂王更懂Ai。回答各类AI相关问题。

【说话风格】
说话极简，像微信聊天一样频繁换行。每行不超过15字。严禁标点，严禁说"亲"或"您"。

【回答策略】用最简洁的方式回答，不要长篇大论，像朋友聊天一样。涉及价格统一用标准回复。""",

        "knowledge": """我是懂王Ai的懂小智，比懂王更懂Ai。分享行业知识。

【说话风格】
说话极简，像微信聊天一样频繁换行。每行不超过15字。严禁标点，严禁说"亲"或"您"。

【分享策略】用通俗的方式解释技术概念，不要学术化。结合行业趋势和就业前景。适当引导对课程的兴趣。""",
    }
    return prompts.get(category, prompts["sales"])


def _format_custom_item(item: CustomConversation, format: str, include_system_prompt: bool = True) -> Optional[dict]:
    """
    将自定义数据转换为指定的导出格式
    """
    if not item.conversation_json or len(item.conversation_json) < 2:
        return None

    # 获取类别和系统提示
    category = item.category or 'sales'
    system_prompt = _get_system_prompt_for_category(category) if include_system_prompt else None

    # 构造标准 Messages 列表
    messages = []

    if system_prompt:
        messages.append({"role": "system", "content": system_prompt})

    # 添加对话轮次
    for turn in item.conversation_json:
        role = turn.get("role", "user")
        content = turn.get("content", "")

        if content and role in ["user", "assistant", "system"]:
            messages.append({"role": role, "content": content})

    # 过滤掉没有实质对话的
    if len(messages) <= 1:  # 只有 system prompt
        return None

    # 转换为最终格式
    if format == "sharegpt":
        conversations = []
        for msg in messages:
            # Include system message in conversations list for ShareGPT
            role_map = {"user": "human", "assistant": "gpt", "system": "system"}
            if msg["role"] in role_map:
                conversations.append({"from": role_map[msg["role"]], "value": msg["content"]})

        # 应用训练数据清洗：修复gpt先开口、移除不完整对话、价格脱敏、过滤过短/过长对话
        conversations = _clean_conversation_for_training(
            conversations, 
            desensitize_price=True,
            validate_style=True,
            min_turns=4,  # 至少 4 条消息（2轮对话）
            max_turns=40  # 最多 40 条消息
        )
        
        # 如果清洗后没有有效对话，返回 None
        if len(conversations) < 2:
            return None

        result = {
            "id": f"custom_{item.id}",
            "conversations": conversations,
            "category": category,
            "quality": item.quality or "high",
            "source": "custom"
        }

        return result

    elif format == "alpaca":
        # Alpaca 只能存一组对话，取第一组 User/Assistant
        user_msg = next((m["content"] for m in messages if m["role"] == "user"), "")
        assist_msg = next((m["content"] for m in messages if m["role"] == "assistant"), "")

        return {
            "instruction": user_msg or "请分析以下内容",
            "input": "",
            "output": assist_msg,
            "category": category,
            "source": "custom"
        }

    elif format == "rag":
        # RAG 知识库格式：从 conversation_json 中提取首个 user→assistant 问答对
        user_msgs = [m["content"] for m in messages if m["role"] == "user"]
        assist_msgs = [m["content"] for m in messages if m["role"] == "assistant"]
        
        question = user_msgs[0] if user_msgs else ""
        # 合并所有 assistant 回复作为完整回答
        answer = "\n".join(assist_msgs) if assist_msgs else ""
        
        if not question or not answer:
            return None
        
        # 价格脱敏
        question = _desensitize_price(question)
        answer = _desensitize_price(answer)
        # 清理残留占位符
        question = _replace_resource_links(question)
        answer = _replace_resource_links(answer)
        # 风格验证（仅对 answer 做风格修复）
        answer, _ = _validate_and_fix_gpt_response(answer, category)
        
        return {
            "question": question.strip(),
            "answer": answer.strip(),
            "category": category,
            "source": "custom"
        }

    elif format in ["openai", "jsonl"]:
        # OpenAI 格式：先转换为 sharegpt 格式清洗，再转回来
        conversations = []
        for msg in messages:
            role_map = {"user": "human", "assistant": "gpt", "system": "system"}
            if msg["role"] in role_map:
                conversations.append({"from": role_map[msg["role"]], "value": msg["content"]})
        
        # 应用训练数据清洗：过滤过短/过长对话、价格脱敏
        conversations = _clean_conversation_for_training(
            conversations, 
            desensitize_price=True,
            validate_style=True,
            min_turns=4,  # 至少 4 条消息（2轮对话）
            max_turns=40  # 最多 40 条消息
        )
        
        # 如果清洗后没有有效对话，返回 None
        if len(conversations) < 2:
            return None
        
        # 转回 OpenAI messages 格式
        cleaned_messages = []
        for conv in conversations:
            role_map = {"human": "user", "gpt": "assistant", "system": "system"}
            cleaned_messages.append({
                "role": role_map[conv["from"]],
                "content": conv["value"]
            })
        
        return {"messages": cleaned_messages, "source": "custom"}

    return None
