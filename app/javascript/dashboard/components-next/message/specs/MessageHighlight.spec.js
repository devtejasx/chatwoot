import { ref } from 'vue';
import { shallowMount } from '@vue/test-utils';
import { emitter } from 'shared/helpers/mitt';
import { BUS_EVENTS } from 'shared/constants/busEvents';
import Message from '../Message.vue';

vi.mock('dashboard/composables', () => ({ useTrack: vi.fn() }));
vi.mock('dashboard/composables/store', () => ({
  useMapGetter: () => ref(() => ({})),
}));
vi.mock('vue-router', () => ({ useRoute: () => ({ query: {} }) }));
vi.mock('vue-i18n', () => ({ useI18n: () => ({ t: key => key }) }));

const mountMessage = id =>
  shallowMount(Message, {
    props: {
      id,
      messageType: 0,
      status: 'sent',
      content: 'Hello',
      conversationId: 1,
      createdAt: 1700000000,
      currentUserId: 1,
    },
  });

describe('Message highlight on scroll to message', () => {
  beforeEach(() => {
    vi.useFakeTimers();
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it('highlights the message that a reply preview scrolls to', async () => {
    const wrapper = mountMessage(10);

    emitter.emit(BUS_EVENTS.SCROLL_TO_MESSAGE, { messageId: 10 });
    await wrapper.vm.$nextTick();
    expect(wrapper.classes()).toContain('bg-n-alpha-1');

    vi.advanceTimersByTime(1000);
    await wrapper.vm.$nextTick();
    expect(wrapper.classes()).not.toContain('bg-n-alpha-1');
    wrapper.unmount();
  });

  it('does not highlight other messages', async () => {
    const wrapper = mountMessage(11);

    emitter.emit(BUS_EVENTS.SCROLL_TO_MESSAGE, { messageId: 10 });
    emitter.emit(BUS_EVENTS.SCROLL_TO_MESSAGE);
    await wrapper.vm.$nextTick();
    expect(wrapper.classes()).not.toContain('bg-n-alpha-1');
    wrapper.unmount();
  });
});
