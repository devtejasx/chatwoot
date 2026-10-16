import ConversationWrap from '../ConversationWrap.vue';
import { MESSAGE_TYPE } from 'shared/constants/messages';

const { showStatusIndicator } = ConversationWrap.computed;

const buildContext = (overrides = {}) => ({
  conversationAttributes: { status: 'pending' },
  lastMessage: { id: 10, message_type: MESSAGE_TYPE.INCOMING },
  isAgentTyping: false,
  typingStoppedAtMessageId: null,
  ...overrides,
});

describe('ConversationWrap showStatusIndicator', () => {
  it('shows the indicator while a pending conversation waits for a reply', () => {
    expect(showStatusIndicator.call(buildContext())).toBe(true);
  });

  it('hides the indicator after typing was turned off at the last message', () => {
    const context = buildContext({ typingStoppedAtMessageId: 10 });
    expect(showStatusIndicator.call(context)).toBe(false);
  });

  it('shows the indicator again for a newer incoming message', () => {
    const context = buildContext({
      lastMessage: { id: 11, message_type: MESSAGE_TYPE.INCOMING },
      typingStoppedAtMessageId: 10,
    });
    expect(showStatusIndicator.call(context)).toBe(true);
  });

  it('shows the indicator while the agent is typing', () => {
    const context = buildContext({
      isAgentTyping: true,
      typingStoppedAtMessageId: 10,
    });
    expect(showStatusIndicator.call(context)).toBe(true);
  });
});
